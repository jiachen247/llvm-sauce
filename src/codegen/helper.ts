import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, Location } from '../context/environment'
import { LLVMObjs } from '../types/types'
import {
  NUMBER_TYPE_CODE,
  BOOLEAN_TYPE_CODE,
  STRING_TYPE_CODE,
  FUNCTION_TYPE_CODE,
  UNDEFINED_TYPE_CODE
} from './constants'

function scanOutDir(nodes: Array<es.Node>, env: Environment): number {
  let count = 0

  for (let node of nodes) {
    if (node.type === 'VariableDeclaration') {
      count += 1
      const decl = (node as es.VariableDeclaration).declarations[0]
      const id = decl.id
      let name: string | undefined
      if (id.type === 'Identifier') name = id.name

      env.addRecord(name!)
    } else if (node.type === 'FunctionDeclaration') {
      count += 1
      const decl = node as es.FunctionDeclaration
      env.addRecord(decl.id!.name)
    }
  }
  return count
}

function createEnv(count: number, lObj: LLVMObjs): l.Value {
  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)
  // size + 1 for env parent ptr  (already included in params.length)
  const size = count * 8 // 64 bit
  // env registers start with e

  const addr = malloc(size, lObj, 'env')
  return lObj.builder.createBitCast(addr, literalStructPtr)
}

// jump is the number of back pointers to follow in the env
function lookupEnv(name: string, frame: Environment): Location {
  let jumps = 0
  let currentFrame = frame

  while (true) {
    if (currentFrame.contains(name)) {
      const offset = currentFrame.get(name)!.offset
      return { jumps, offset }
    }

    const parent = currentFrame.getParent()
    if (!parent) {
      throw new Error('Cannot find name ' + name)
    } else {
      currentFrame = parent
      jumps += 1
    }
  }
}

function mallocByValue(sizeValue: l.Value, lObj: LLVMObjs, name?: string) {
  const mallocFunType = l.FunctionType.get(
    l.Type.getInt8PtrTy(lObj.context),
    [l.Type.getInt64Ty(lObj.context)],
    false
  )

  const mallocFun = lObj.module.getOrInsertFunction('malloc', mallocFunType)
  return lObj.builder.createCall(mallocFun.functionType, mallocFun.callee, [sizeValue], name)
}

function malloc(size: number, lObj: LLVMObjs, name?: string) {
  const sizeValue = l.ConstantInt.get(lObj.context, size, 64)

  return mallocByValue(sizeValue, lObj, name)
}

function display(args: l.Value[], env: Environment, lObj: LLVMObjs): l.CallInst {
  const displayFunction = lObj.module.getFunction('display')!
  if (args.length < 1) {
    console.error('display requires one arguement')
  }
  return lObj.builder.createCall(
    displayFunction.type.elementType,
    lObj.module.getFunction('display')!,
    args
  )
}

function errorWithString(str: string, lObj: LLVMObjs) {
  const value = lObj.builder.createGlobalStringPtr(str)
  errorWithValue(value, lObj)
}

function errorWithValue(message: l.Value, lObj: LLVMObjs) {
  // print error then call exit
  const errorFunctionType = l.FunctionType.get(
    l.Type.getVoidTy(lObj.context),
    [l.Type.getInt8PtrTy(lObj.context)],
    false
  )

  const error = lObj.module.getOrInsertFunction('error', errorFunctionType)
  lObj.builder.createCall(error.functionType, error.callee, [message])

  const exitType = l.FunctionType.get(
    l.Type.getVoidTy(lObj.context),
    [l.Type.getInt32Ty(lObj.context)],
    false
  )

  const one = l.ConstantInt.get(lObj.context, 1)
  const exit = lObj.module.getOrInsertFunction('exit', exitType)
  lObj.builder.createCall(exit.functionType, exit.callee, [one])
}

function getNumberTypeCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, NUMBER_TYPE_CODE)
}

function getBooleanTypeCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, BOOLEAN_TYPE_CODE)
}

function getStringTypeCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, STRING_TYPE_CODE)
}

function getFunctionTypeCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, FUNCTION_TYPE_CODE)
}

function getUndefinedCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, UNDEFINED_TYPE_CODE)
}

function createNewFunctionEnvironment(
  params: Array<es.Pattern>,
  body: Array<es.Node>,
  parent: Environment,
  parentAddress: l.Value, // passed as first arg
  lObj: LLVMObjs
) {
  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)

  const env = Environment.createNewEnvironment(parent)

  params.map(param => env.addRecord((param as es.Identifier).name))

  const environmentSize = params.length + scanOutDir(body, env)
  const envValue = createEnv(environmentSize, lObj)
  const framePtr = lObj.builder.createBitCast(envValue, literalStructPtrPtr)
  lObj.builder.createStore(parentAddress, framePtr)

  env.setPointer(envValue)
  env.setParent(parent)

  return env
}

function createNewEnvironment(
  body: Array<es.Node>,
  parent: Environment | undefined,
  lObj: LLVMObjs
) {
  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)
  // const literalStructPtrPtrPtr = l.PointerType.get(literalStructPtrPtr, 0)

  const env = Environment.createNewEnvironment(parent)
  const environmentSize = scanOutDir(body, env)
  const envValue = createEnv(environmentSize, lObj)
  env.setPointer(envValue)

  if (parent) {
    const parentAddr = parent.getPointer()!
    const framePtr = lObj.builder.createBitCast(envValue, literalStructPtrPtr)
    lObj.builder.createStore(parentAddr, framePtr)
    env.setParent(parent)
  }

  return env
}

function throwRuntimeTypeError(lObj: LLVMObjs) {
  errorWithString('boo type mismatch', lObj)
}

function createArgumentContainer(params: l.Value[], lObj: LLVMObjs) {
  const n = params.length

  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)
  // size + 1 for env parent ptr  (already included in params.length)
  const size = n * 8 // 64 bit

  const raw = malloc(size, lObj, 'params')
  const addr = lObj.builder.createBitCast(raw, literalStructPtrPtr)
  let base
  for (let i = 0; i < n; i++) {
    base = lObj.builder.createInBoundsGEP(literalStructPtr, addr, [
      l.ConstantInt.get(lObj.context, i)
    ])
    lObj.builder.createStore(params[i], base)
  }

  return lObj.builder.createBitCast(addr, literalStructPtrPtr)
}

export {
  scanOutDir,
  createEnv,
  lookupEnv,
  malloc,
  mallocByValue,
  display,
  getNumberTypeCode,
  getBooleanTypeCode,
  getStringTypeCode,
  getFunctionTypeCode,
  getUndefinedCode,
  errorWithString,
  errorWithValue,
  createNewEnvironment,
  createNewFunctionEnvironment,
  throwRuntimeTypeError,
  createArgumentContainer
}
