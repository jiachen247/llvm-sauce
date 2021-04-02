import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { evaluateExpression } from '../codegen'
import {
  display,
  getFunctionTypeCode,
  throwRuntimeTypeError,
  createArgumentContainer
} from '../helper'

function typecheckFunction(code: l.Value, lObj: LLVMObjs) {
  const error = l.BasicBlock.create(lObj.context, 'error', lObj.function!)
  const next = l.BasicBlock.create(lObj.context, 'next', lObj.function!)

  const isFunction = lObj.builder.createFCmpOEQ(code, getFunctionTypeCode(lObj))
  lObj.builder.createCondBr(isFunction, next, error)

  lObj.builder.setInsertionPoint(error)
  throwRuntimeTypeError(lObj)
  lObj.builder.createBr(next) // will never get there!

  lObj.builder.setInsertionPoint(next)
}

function evalCallExpression(node: es.CallExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const params = node.arguments.map(x => evaluateExpression(x, env, lObj))

  // check for builtins
  if (node.callee.type === 'Identifier') {
    const callee = (node.callee as es.Identifier).name
    const builtins: { [id: string]: () => l.CallInst } = {
      display: () => display(params, env, lObj)
    }

    if (builtins[callee]) {
      return builtins[callee]()
    }
  }

  const callee = evaluateExpression(node.callee, env, lObj)

  const literalStructType = lObj.module.getTypeByName('literal')!

  const functionStructType = lObj.module.getTypeByName('function_literal')!
  const functionStructTypePtr = l.PointerType.get(functionStructType, 0)!

  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)
  const two = l.ConstantInt.get(lObj.context, 2)

  const litType = lObj.builder.createInBoundsGEP(literalStructType, callee, [zero, zero])
  const litTypeValue = lObj.builder.createLoad(litType)

  typecheckFunction(litTypeValue, lObj)
  const functionLit = lObj.builder.createBitCast(callee, functionStructTypePtr)

  const funObjAddr = lObj.builder.createInBoundsGEP(functionStructType, functionLit, [zero, two])
  const functionObj = lObj.builder.createLoad(funObjAddr)

  const funEnvAddr = lObj.builder.createInBoundsGEP(functionStructType, functionLit, [zero, one])
  const funEnv = lObj.builder.createLoad(funEnvAddr)

  const paramsBox = createArgumentContainer(params, lObj)

  return lObj.builder.createCall(functionObj, [funEnv, paramsBox])
}

export { evalCallExpression }
