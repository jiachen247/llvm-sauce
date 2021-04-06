import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { evaluateExpression } from '../codegen'
import { createUndefinedLiteral, createFunctionLiteral } from '../expression/literal'
import { createNewFunctionEnvironment, lookupEnvAndSetValue } from '../helper'
import { evalBlockStatement } from '../statement/block'
import { containTailCalls } from '../tailcall'

function formatFunctionName(name?: string) {
  return name ? `__${name}` : `__anon`
}

function evalFunctionExpression(
  node: es.BaseFunction,
  parent: Environment,
  isExpressionBased: boolean,
  lObj: LLVMObjs,
  containsTailCalls: boolean,
  name?: string
): l.Value {
  const resumePoint = lObj.builder.getInsertBlock()!
  const prevFunctionContext = lObj.functionContext
  // ----------------------------------------------------

  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)

  const numberOfParameters = node.params.length

  const genericFunctionType = l.FunctionType.get(
    literalStructPtr,
    [literalStructPtrPtr, literalStructPtrPtr],
    false
  )

  const fun = l.Function.create(
    genericFunctionType,
    l.LinkageTypes.ExternalLinkage,
    formatFunctionName(name),
    lObj.module
  )

  const setup = l.BasicBlock.create(lObj.context, 'f.setup', fun)
  const entry = l.BasicBlock.create(lObj.context, 'f.entry', fun)
  lObj.builder.setInsertionPoint(setup)

  const enclosingFrame = fun.getArguments()[0]! // first arg
  const paramsAddr = fun.getArguments()[1]!

  const env = createNewFunctionEnvironment(
    node.params,
    isExpressionBased ? [] : (node.body as es.BlockStatement).body,
    parent,
    enclosingFrame,
    lObj
  )

  const params = lObj.builder.createBitCast(paramsAddr, literalStructPtrPtr)
  const thisEnv = lObj.builder.createBitCast(env.getPointer()!, literalStructPtrPtr)
  const paramsNames = node.params.map(param => (param as es.Identifier).name)
  let paramValues = []
  let base, value, target
  for (let i = 0; i < numberOfParameters; i++) {
    base = lObj.builder.createInBoundsGEP(literalStructPtr, params, [
      l.ConstantInt.get(lObj.context, i)
    ])
    
    value = lObj.builder.createLoad(base)
    env.get(paramsNames[i])!.value = value
    
    target = lObj.builder.createInBoundsGEP(literalStructPtr, thisEnv, [
      l.ConstantInt.get(lObj.context, i + 1)
    ])
    lObj.builder.createStore(value, target)
    paramValues.push(value)
  }

  // ======
  lObj.builder.createBr(entry)
  lObj.builder.setInsertionPoint(entry)

  lObj.functionContext = {
    function: fun,
    name: name,
    env: env,
    entry: entry,
    udef: undefined,
    phis: []
  }

  if (containsTailCalls) {
    for (let i = 0; i < numberOfParameters; i++) {
        const phi = lObj.builder.createPhi(literalStructPtr, 2)
        phi.addIncoming(paramValues[i], setup)
        lObj.functionContext!.phis!.push(phi)
        env.get(paramsNames[i])!.value = phi
    }
  }
  if (isExpressionBased) {
    // lambda expression
    const res = evaluateExpression(node.body, env, lObj)
    lObj.builder.createRet(res)
  } else {
    evalBlockStatement(node.body, env, lObj)
  }

  if (!lObj.builder.getInsertBlock()!.getTerminator()) {
    const udef = createUndefinedLiteral(lObj)
    lObj.builder.createRet(udef)
  }

  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(lObj.module.print())
    throw e
  }

  // ----------------------------------------------------------------
  lObj.builder.setInsertionPoint(resumePoint)
  lObj.functionContext = prevFunctionContext

  return createFunctionLiteral(fun, parent.getPointer()!, lObj)
}

function evalArrowFunctionExpression(
  node: es.ArrowFunctionExpression,
  parent: Environment,
  lObj: LLVMObjs
) {
  return evalFunctionExpression(node, parent, node.expression, lObj, false)
}

function evalFunctionStatement(node: es.FunctionDeclaration, parent: Environment, lObj: LLVMObjs) {
  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)

  const name = node.id!.name

  const lit = evalFunctionExpression(node, parent, false, lObj, lObj.config.tco ? containTailCalls(node, name) : false, name)

  let frame = parent.getPointer()!
  // for source 1 it should be the immediate frame
  const { jumps, offset } = lookupEnvAndSetValue(name, parent, lit)

  // jump should always be zero
  for (let i = 0; i < jumps; i++) {
    const tmp = lObj.builder.createBitCast(frame, l.PointerType.get(frame.type, 0)!)
    frame = lObj.builder.createLoad(tmp)
  }

  const frame_casted = lObj.builder.createBitCast(frame, literalStructPtrPtr)
  const ptr = lObj.builder.createInBoundsGEP(literalStructPtr, frame_casted, [
    l.ConstantInt.get(lObj.context, offset)
  ])

  lObj.builder.createStore(lit, ptr, false)

  // cache as virtual
  parent.addVirtual(name, lit)

  return lit
}

export { evalFunctionStatement, formatFunctionName, evalArrowFunctionExpression }
