import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { malloc } from '../helper'
import { getNumberTypeCode, getBooleanTypeCode, getStringTypeCode, getFunctionTypeCode } from '../helper'

const SIZE_OF_DATA_NODE = 16 // jiachen is very generous

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

function createCompileTimeStringLiteral(str: string, lObj: LLVMObjs): l.Value {
  const strPtr = lObj.builder.createGlobalStringPtr(str, 's')
  return createStringLiteral(strPtr, lObj)
}

function createStringLiteral(str: l.Value, lObj: LLVMObjs): l.Value {
  const code = getStringTypeCode(lObj)

  const stringLiteral = l.PointerType.get(lObj.module.getTypeByName('string_literal')!, 0)
  const literalStructPtr = l.PointerType.get(lObj.module.getTypeByName('literal')!, 0)

  const raw: l.Value = malloc(SIZE_OF_DATA_NODE, lObj)

  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const literal = lObj.builder.createBitCast(raw, stringLiteral)
  const typePtr = lObj.builder.createInBoundsGEP(literal, [zero, zero])
  const valuePtr = lObj.builder.createInBoundsGEP(literal, [zero, one])

  lObj.builder.createStore(code, typePtr, false)
  lObj.builder.createStore(str, valuePtr, false)

  return lObj.builder.createBitCast(literal, literalStructPtr)
}


function createFunctionLiteral(fun: l.Function, env: l.Value, lObj: LLVMObjs): l.Value {
  const code = getFunctionTypeCode(lObj)

  const functionLiteralPtr = l.PointerType.get(lObj.module.getTypeByName('function_literal')!, 0)
  const literalStructPtr = l.PointerType.get(lObj.module.getTypeByName('literal')!, 0)

  const raw: l.Value = malloc(SIZE_OF_DATA_NODE, lObj)

  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)
  const two = l.ConstantInt.get(lObj.context, 2)

  const literal = lObj.builder.createBitCast(raw, functionLiteralPtr)
  const typePtr = lObj.builder.createInBoundsGEP(literal, [zero, zero])
  const envPtr = lObj.builder.createInBoundsGEP(literal, [zero, one])
  const funPtr = lObj.builder.createInBoundsGEP(literal, [zero, two])

  lObj.builder.createStore(code, typePtr, false)
  lObj.builder.createStore(env, envPtr, false)
  lObj.builder.createStore(fun, funPtr, false)

  /*
    l.Type.getDoubleTy(context), 
    l.PointerType.get(structType, 0), // enclosing env
    l.PointerType.get(genericFunctionType, 0) // function pointer
  */

  return lObj.builder.createBitCast(literal, literalStructPtr)
}

/*
literal
-----------------
| double: type  |
| double: value |
-----------------

string literal
-----------------
| double: type  |
| pointer: str  |
-----------------

function literal
-----------------
| double: type  |
| pointer: str  |
-----------------
*/
function evalLiteralExpression(node: es.Literal, env: Environment, lObj: LLVMObjs): l.Value {
  let value = node.value
  // malloc 16 bytes
  // write type to offset 0
  // wirte data to offset 16

  switch (typeof value) {
    case 'string':
      return createCompileTimeStringLiteral(value, lObj)
    case 'number':
      return createNumberLiteral(value, lObj)
    case 'boolean':
      return createBooleanLiteral(value, lObj)
    default:
      throw new Error('Unimplemented literal type ' + typeof value)
  }
}

export { evalLiteralExpression, createLiteral, createStringLiteral, createFunctionLiteral}
