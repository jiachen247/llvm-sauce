import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, TypeRecord } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { getNumberTypeCode, getBooleanTypeCode, getStringTypeCode } from '../helper'
import { createLiteral } from './literal'
import { evaluateExpression } from '../codegen'

function evalUnaryExpression(node: es.UnaryExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const NUMBER_CODE = getNumberTypeCode(lObj)
  const BOOLEAN_CODE = getBooleanTypeCode(lObj)
  const STRING_CODE = getStringTypeCode(lObj)

  const operator: string = node.operator
  const arg = evaluateExpression(node.argument, env, lObj)

  const literalStruct = lObj.module.getTypeByName('literal')!
  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const expr = lObj.builder.createInBoundsGEP(literalStruct, arg, [zero, one])

  const exprValue = lObj.builder.createLoad(expr)

  const intType = l.Type.getInt64Ty(lObj.context)
  const doubleType = l.Type.getDoubleTy(lObj.context)

  let value, retType, tmp

  switch (operator) {
    case '!':
      /*
      display(true);
      display(!true);
      display(false);
      display(!false);
      node {2.000000, 1.000000}
      node {2.000000, -2.000000}
      node {2.000000, 0.000000}
      node {2.000000, -1.000000}
      todo fix this!
      */
      const exprInt = lObj.builder.createFPToSI(exprValue, intType)
      tmp = lObj.builder.createNot(exprInt)
      value = lObj.builder.createSIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '-':
      value = lObj.builder.createFNeg(exprValue)
      retType = NUMBER_CODE
      break
    default:
      throw new Error('Unknown unary operator ' + operator)
  }

  return createLiteral(value, retType, lObj)
}

export { evalUnaryExpression }
