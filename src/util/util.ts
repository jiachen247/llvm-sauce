import * as l from 'llvm-node'
import { Type } from '../context/environment'

function isBool(x: l.Value) {
  return x.type.isIntegerTy() && (x.type as l.IntegerType).getBitWidth() === 1
}

function isString(x: l.Value) {
  return x.type.isPointerTy() && x.name.search('str')
}

function isNumber(x: l.Value) {
  return x.type.isDoubleTy()
}

function getType(value: l.Value) : Type {
  return isNumber(value)
    ? Type.NUMBER
    : isBool(value)
    ? Type.BOOLEAN
    : isString(value)
    ? Type.STRING
    : Type.UNKNOWN
}

function getLLVMType(type: Type, context: l.LLVMContext) : l.Type {
  return type === Type.NUMBER
    ? l.Type.getDoubleTy(context)
    : type === Type.BOOLEAN
    ? l.Type.getInt1Ty(context)
    : l.Type.getVoidTy(context)
}

export { isBool, isString, isNumber, getLLVMType, getType }
