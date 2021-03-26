import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, TypeRecord } from '../context/environment'
import { LLVMObjs, Location } from '../types/types'
import { NUMBER_TYPE_CODE, BOOLEAN_TYPE_CODE, STRING_TYPE_CODE } from './constants'

// function getNumberTypeCode() {

// }

function scanOutDir(nodes: Array<es.Node>, env: Environment): number {
  let count = 0

  for (let node of nodes) {
    if (node.type === 'VariableDeclaration') {
      count += 1
      const decl = (node as es.VariableDeclaration).declarations[0]
      const id = decl.id
      let name: string | undefined
      if (id.type === 'Identifier') name = id.name

      env.addRecord(name!, count)
    }
  }
  return count
}

function createEnv(count: number, lObj: LLVMObjs): l.Value {
  // size + 1 for env parent ptr
  const size = (count + 1) * 8 // 64 bit
  // env registers start with e
  return malloc(size, lObj, 'e')
}

// jump is the number of back pointers to follow in the env
function lookup_env(name: string, frame: Environment): Location {
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

function getNumberTypeCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, NUMBER_TYPE_CODE)
}

function getBooleanTypeCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, BOOLEAN_TYPE_CODE)
}

function getStringTypeCode(lObj: LLVMObjs): l.Value {
  return l.ConstantFP.get(lObj.context, STRING_TYPE_CODE)
}

export {
  scanOutDir,
  createEnv,
  lookup_env,
  malloc,
  mallocByValue,
  display,
  getNumberTypeCode,
  getBooleanTypeCode,
  getStringTypeCode
}
