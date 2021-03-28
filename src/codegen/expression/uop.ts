import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { getNumberTypeCode, getBooleanTypeCode, getStringTypeCode, throwRuntimeTypeError } from '../helper'
import { createLiteral } from './literal'
import { evaluateExpression } from '../codegen'

function typecheck(actual: l.Value, expected: l.Value, lObj: LLVMObjs) {
  const error = l.BasicBlock.create(lObj.context, 'tc.error', lObj.function!)
  const valid = l.BasicBlock.create(lObj.context, 'tc.valid', lObj.function!)

  const isValid = lObj.builder.createFCmpOEQ(actual, expected)
  lObj.builder.createCondBr(isValid, valid, error)
  

  lObj.builder.setInsertionPoint(error)
  throwRuntimeTypeError(lObj)
  lObj.builder.createBr(valid) // wont get here!

  lObj.builder.setInsertionPoint(valid)
}

function evalUnaryExpression(node: es.UnaryExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const NUMBER_CODE = getNumberTypeCode(lObj)
  const BOOLEAN_CODE = getBooleanTypeCode(lObj)
  const STRING_CODE = getStringTypeCode(lObj)

  const operator: string = node.operator
  const arg = evaluateExpression(node.argument, env, lObj)

  const literalStruct = lObj.module.getTypeByName('literal')!
  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const typeAddr = lObj.builder.createInBoundsGEP(literalStruct, arg, [zero, zero])

  const exprAddr = lObj.builder.createInBoundsGEP(literalStruct, arg, [zero, one])

  const typeValue = lObj.builder.createLoad(typeAddr)
  const exprValue = lObj.builder.createLoad(exprAddr)

  const i1 = l.Type.getInt1Ty(lObj.context)
  const intType = l.Type.getInt64Ty(lObj.context)
  const doubleType = l.Type.getDoubleTy(lObj.context)

  let value, retType, tmp

  switch (operator) {
    case '!':
      typecheck(typeValue, BOOLEAN_CODE, lObj)
      const exprInt = lObj.builder.createFPToSI(exprValue, i1)
      tmp = lObj.builder.createNot(exprInt)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '-':
      typecheck(typeValue, NUMBER_CODE, lObj)
      value = lObj.builder.createFNeg(exprValue)
      retType = NUMBER_CODE
      break
    default:
      throw new Error('Unknown unary operator ' + operator)
  }

  return createLiteral(value, retType, lObj)
}

export { evalUnaryExpression }
