import { Value, IntegerType } from 'llvm-node'
import * as es from 'estree'

function isBool(x: Value) {
  return x.type.isIntegerTy() && (x.type as IntegerType).getBitWidth() === 1
}

function isString(x: Value) {
  return x.type.isPointerTy() && x.name.search('str')
}

function isNumber(x: Value) {
  return x.type.isDoubleTy()
}

export { isBool, isString, isNumber }
