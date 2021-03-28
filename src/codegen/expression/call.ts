import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { evaluateExpression } from '../codegen'
import {
  display,
  getFunctionTypeCode,
  lookupEnv,
  throwRuntimeTypeError,
  createArgumentContainer
} from '../helper'
import { formatFunctionName } from '../statement/function'

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
  const callee = (node.callee as es.Identifier).name

  const params = node.arguments.map(x => evaluateExpression(x, env, lObj))

  const builtins: { [id: string]: () => l.CallInst } = {
    display: () => display(params, env, lObj)
  }

  const built = builtins[callee]
  let fun

  if (!built) {
    const loc = lookupEnv(callee, env)
    let frame = env.getPointer()! // frame enclosing function eyeballs

    const literalStructType = lObj.module.getTypeByName('literal')!
    const literalStructPtr = l.PointerType.get(literalStructType, 0)!
    const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)!

    const functionStructType = lObj.module.getTypeByName('function_literal')!
    const functionStructTypePtr = l.PointerType.get(functionStructType, 0)!

    let tmp
    for (let i = 0; i < loc.jumps; i++) {
      tmp = lObj.builder.createBitCast(frame, literalStructPtrPtr)
      frame = lObj.builder.createLoad(tmp)
    }
    tmp = lObj.builder.createBitCast(frame, literalStructPtrPtr)

    // place this frame as the first arg

    const zero = l.ConstantInt.get(lObj.context, 0)
    const one = l.ConstantInt.get(lObj.context, 1)
    const two = l.ConstantInt.get(lObj.context, 2)

    const functionLitAddress = lObj.builder.createInBoundsGEP(literalStructPtr, tmp, [
      l.ConstantInt.get(lObj.context, loc.offset)
    ])
    const functLiteralPtr = lObj.builder.createLoad(functionLitAddress)
    const functionPtrCast = lObj.builder.createBitCast(functLiteralPtr, functionStructTypePtr)

    const funTypeAddress = lObj.builder.createInBoundsGEP(functionStructType, functionPtrCast, [
      zero,
      zero
    ])
    const functionType = lObj.builder.createLoad(funTypeAddress)

    typecheckFunction(functionType, lObj)

    const funObjAddr = lObj.builder.createInBoundsGEP(functionStructType, functionPtrCast, [
      zero,
      two
    ])
    const functionObj = lObj.builder.createLoad(funObjAddr)

    const funEnvAddr = lObj.builder.createInBoundsGEP(functionStructType, functionPtrCast, [
      zero,
      one
    ])
    const funEnv = lObj.builder.createLoad(funEnvAddr)

    const paramsBox = createArgumentContainer(params, lObj)

    return lObj.builder.createCall(functionObj, [funEnv, paramsBox])
  } else {
    return built() // a bit of that lazy evaluation
  }
}

export { evalCallExpression }
