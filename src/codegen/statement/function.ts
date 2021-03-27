import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { NUMBER_TYPE_CODE } from '../constants'
import { createLiteral, createFunctionLiteral } from '../expression/literal'
import { createNewFunctionEnvironment, getNumberTypeCode, lookup_env } from '../helper'
import { evalBlockStatement } from '../statement/block'

function formatFunctionName(name: string) {
  return `__${name}`
}

function evalFunctionStatement(
  node: es.FunctionDeclaration,
  parent: Environment,
  lObj: LLVMObjs
) {
  const resumePoint = lObj.builder.getInsertBlock()!
  const prevFunction = lObj.function!
  // ----------------------------------------------------

  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)

  const numberOfParameters = node.params.length + 1 // +1 for parent env
  let argDef = []

  for (let i = 0; i < numberOfParameters; i++) {
    argDef.push(literalStructPtr)
  }

  const genericFunctionType = l.FunctionType.get(
    literalStructPtr,
    [literalStructPtr],
    true
  )

  const fun = l.Function.create(
    genericFunctionType,
    l.LinkageTypes.ExternalLinkage,
    formatFunctionName(node.id!.name),
    lObj.module
  )

  lObj.function = fun

  const entry = l.BasicBlock.create(lObj.context, 'f.entry', fun)
  lObj.builder.setInsertionPoint(entry)

  const parentAddress = fun.getArguments()[0]! // first arg
  const env = createNewFunctionEnvironment(node.params, node.body.body, parent, parentAddress, lObj)

  // load args into the bew env
  const base = fun.getArguments()[0]!
  for (let i = 1; i < numberOfParameters; i++) {
    
    const name = (node.params[i-1] as es.Identifier).name
    const loc = lookup_env(name, env)
    // guranteed to be the imm frame since params

    const ptr = lObj.builder.createInBoundsGEP(literalStructPtr, env.getPointer()!, [
      l.ConstantInt.get(lObj.context, loc.offset)
    ])

    const bastPtr = lObj.builder.createBitCast(bastPtr, )

    const arg = lObj.builder.createInBoundsGEP(literalStructPtr, env.getPointer()!, [
      l.ConstantInt.get(lObj.context, loc.offset)
    ])
  
  
    console.log(fun.getArguments())
    lObj.builder.createStore(arg, ptr, true)
  }

  evalBlockStatement(node.body, env, lObj)
  const one = l.ConstantFP.get(lObj.context, 1)
  const null1 = createLiteral(one, getNumberTypeCode(lObj), lObj)

  lObj.builder.createRet(null1) // dont know if this is allowed

  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(lObj.module.print())
    throw e
  }

  // ----------------------------------------------------------------
  lObj.builder.setInsertionPoint(resumePoint)
  lObj.function = prevFunction

  const lit = createFunctionLiteral(fun, parent.getPointer()!, lObj)

  let frame = parent.getPointer()!
  // for source 1 it should be the immediate frame
  const { jumps, offset } = lookup_env(node.id!.name, parent)

  for (let i = 0; i < jumps; i++) {
    const tmp = lObj.builder.createBitCast(frame, l.PointerType.get(frame.type, 0)!)
    frame = lObj.builder.createLoad(tmp)
  }

  const frame_casted = lObj.builder.createBitCast(frame, literalStructPtrPtr)
  const ptr = lObj.builder.createInBoundsGEP(literalStructPtr, frame_casted, [
    l.ConstantInt.get(lObj.context, offset)
  ])

  lObj.builder.createStore(lit, ptr, false)
}

export { evalFunctionStatement, formatFunctionName }
