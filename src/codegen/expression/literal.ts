import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, TypeRecord } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { malloc } from '../helper'
import { getNumberTypeCode, getBooleanTypeCode, getStringTypeCode } from '../helper'

const SIZE_OF_DATA_NODE = 16

// returns a pointer to a data node
function createLiteral(value: l.Value, typeCode: l.Value, lObj: LLVMObjs) {
  const raw: l.Value = malloc(SIZE_OF_DATA_NODE, lObj)
  const literalStructPtr = l.PointerType.get(lObj.module.getTypeByName('literal')!, 0)
  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const literal = lObj.builder.createBitCast(raw, literalStructPtr)
  const typePtr = lObj.builder.createInBoundsGEP(literal, [zero, zero])
  const valuePtr = lObj.builder.createInBoundsGEP(literal, [zero, one])

  // let casted = value

  // // struct defines value to be a double
  // const doubleType = l.Type.getDoubleTy(lObj.context)
  // if (value.type.typeID != doubleType.typeID) {
  //   casted = lObj.builder.createBitCast(value, doubleType)
  // }

  lObj.builder.createStore(typeCode, typePtr, false)
  lObj.builder.createStore(value, valuePtr, false)

  return literal
}

function createNumberLiteral(n: number, lObj: LLVMObjs): l.Value {
  const code = getNumberTypeCode(lObj)
  const numValue = l.ConstantFP.get(lObj.context, n)
  return createLiteral(numValue, code, lObj)
}

function createBooleanLiteral(value: boolean, lObj: LLVMObjs): l.Value {
  const code = getBooleanTypeCode(lObj)
  const boolValue = value ? l.ConstantFP.get(lObj.context, 1) : l.ConstantFP.get(lObj.context, 0)
  return createLiteral(boolValue, code, lObj)
}

function createStringLiteral(str: string, lObj: LLVMObjs) {
  const code = getStringTypeCode(lObj)
  const doubleType = l.Type.getDoubleTy(lObj.context)
  const strPtr = lObj.builder.createGlobalStringPtr(str, 'str')
  const strAsDouble = lObj.builder.createPtrToInt(strPtr, doubleType)
  return createLiteral(strAsDouble, code, lObj)
}

/*
literal
-----------------
| double: type  |
| double: value |
-----------------
*/
function evalLiteralExpression(node: es.Literal, env: Environment, lObj: LLVMObjs): l.Value {
  let value = node.value
  // malloc 16 bytes
  // write type to offset 0
  // wirte data to offset 16

  switch (typeof value) {
    case 'string':
      return createStringLiteral(value, lObj)
    case 'number':
      return createNumberLiteral(value, lObj)
    case 'boolean':
      return createBooleanLiteral(value, lObj)
    default:
      throw new Error('Unimplemented literal type ' + typeof value)
  }
}

export { evalLiteralExpression, createLiteral }
