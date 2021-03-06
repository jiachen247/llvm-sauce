import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { malloc } from '../helper'
import {
  getNumberTypeCode,
  getBooleanTypeCode,
  getStringTypeCode,
  getFunctionTypeCode,
  getUndefinedCode
} from '../helper'

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

  lObj.builder.createStore(typeCode, typePtr, false)
  lObj.builder.createStore(value, valuePtr, false)

  return literal
}

function createUndefinedLiteral(lObj: LLVMObjs) {
  if (lObj.functionContext.udef) {
    return lObj.functionContext.udef
  } else {
    const code = getUndefinedCode(lObj)
    const zero = l.ConstantFP.get(lObj.context, 0)
    const udef = createLiteral(zero, code, lObj)
    lObj.functionContext.udef = udef
    return udef
  }
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

  const functionLiteralType = lObj.module.getTypeByName('function_literal')!
  const functionLiteralPtr = l.PointerType.get(functionLiteralType, 0)
  const literalStructPtr = l.PointerType.get(lObj.module.getTypeByName('literal')!, 0)

  const raw: l.Value = malloc(SIZE_OF_DATA_NODE, lObj)

  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)
  const two = l.ConstantInt.get(lObj.context, 2)

  const literal = lObj.builder.createBitCast(raw, functionLiteralPtr)
  const typePtr = lObj.builder.createInBoundsGEP(functionLiteralType, literal, [zero, zero])
  const envPtr = lObj.builder.createInBoundsGEP(functionLiteralType, literal, [zero, one])
  const funPtr = lObj.builder.createInBoundsGEP(functionLiteralType, literal, [zero, two])

  lObj.builder.createStore(code, typePtr, false)
  lObj.builder.createStore(env, envPtr, false)
  lObj.builder.createStore(fun, funPtr, false)

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
--------------------
| double: type     |
| pointer: env     |
| pointer: functor |
--------------------
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

export {
  evalLiteralExpression,
  createLiteral,
  createStringLiteral,
  createFunctionLiteral,
  createUndefinedLiteral
}
