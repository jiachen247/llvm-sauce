import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { getNumberTypeCode, getBooleanTypeCode, getStringTypeCode } from '../helper'
import { createLiteral } from './literal'

import { evaluateExpression } from '../codegen'

function evalBinaryStatement(
  node: es.BinaryExpression | es.LogicalExpression,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  // todo make global
  const NUMBER_CODE = getNumberTypeCode(lObj)
  const BOOLEAN_CODE = getBooleanTypeCode(lObj)
  const STRING_CODE = getStringTypeCode(lObj)

  const lhs = evaluateExpression(node.left, env, lObj)
  const rhs = evaluateExpression(node.right, env, lObj)

  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const left = lObj.builder.createInBoundsGEP(literalStruct, lhs, [zero, one])
  const right = lObj.builder.createInBoundsGEP(literalStruct, rhs, [zero, one])

  const leftValue = lObj.builder.createLoad(left)
  const rightValue = lObj.builder.createLoad(right)

  const intType = l.Type.getInt64Ty(lObj.context)
  const i1 = l.Type.getInt1Ty(lObj.context)
  const doubleType = l.Type.getDoubleTy(lObj.context)

  // should we do runtime type checks?
  // how to throw error?
  // should refractor
  const operator = node.operator
  let value, retType, tmp, leftValueBool, rightValueBool
  switch (operator) {
    case '+':
      // overload string concat
      // super hacky need to refractor
      const numAddBlock = l.BasicBlock.create(lObj.context, 'num_add', lObj.function)
      const strcatBlock = l.BasicBlock.create(lObj.context, 'str_add', lObj.function)
      const endBlock = l.BasicBlock.create(lObj.context, 'end', lObj.function)

      const lefType = lObj.builder.createInBoundsGEP(literalStruct, lhs, [zero, zero])
      const leftTypeValue = lObj.builder.createLoad(lefType)
      const isBoolean = lObj.builder.createFCmpOEQ(leftTypeValue, NUMBER_CODE)

      lObj.builder.createCondBr(isBoolean, numAddBlock, strcatBlock)

      /* ADD NUMBERS */
      lObj.builder.setInsertionPoint(numAddBlock)
      const valNum = lObj.builder.createFAdd(leftValue, rightValue)
      const valNumNode = createLiteral(valNum, NUMBER_CODE, lObj)
      lObj.builder.createBr(endBlock)

      /* CONCAT STRINGS */
      // TODO FIX
      // llvm node got no inttoptr ins

      lObj.builder.setInsertionPoint(strcatBlock)
      // const str1 = lObj.builder.createIntCast(leftValue, l.Type.getInt8PtrTy(lObj.context), false)
      // const str2 = lObj.builder.createIntCast(rightValue, l.Type.getInt8PtrTy(lObj.context), false)
      // const strcatType = l.FunctionType.get(
      //   l.Type.getInt8PtrTy(lObj.context),
      //   [l.Type.getInt8PtrTy(lObj.context), l.Type.getInt8PtrTy(lObj.context)],
      //   false
      // )
      // const strCatFun = lObj.module.getOrInsertFunction('strcat', strcatType)
      // const val2 = lObj.builder.createCall(strCatFun.functionType, strCatFun.callee, [str1, str2])
      // // const strAsInt = lObj.builder.createPtrToInt(val2, intType)
      // // const strAsDouble = lObj.builder.createUIToFP(strAsInt, doubleType)
      // const valStrNode = createLiteral(val2, STRING_CODE, lObj)
      const broken = createLiteral(l.ConstantFP.get(lObj.context, 1), NUMBER_CODE, lObj)
      lObj.builder.createBr(endBlock)

      lObj.builder.setInsertionPoint(endBlock)
      const phi = lObj.builder.createPhi(literalStructPtr, 2)
      phi.addIncoming(valNumNode, numAddBlock)
      phi.addIncoming(broken, strcatBlock)
      return phi
    case '-':
      value = lObj.builder.createFSub(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '*':
      value = lObj.builder.createFMul(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '/':
      value = lObj.builder.createFDiv(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '%':
      const l1 = lObj.builder.createFPToSI(leftValue, intType)
      const r1 = lObj.builder.createFPToSI(rightValue, intType)
      const v = lObj.builder.createSRem(l1, r1)
      value = lObj.builder.createSIToFP(v, doubleType)
      retType = NUMBER_CODE
      break
    case '<':
      tmp = lObj.builder.createFCmpOLT(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '>':
      tmp = lObj.builder.createFCmpOGT(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '===':
      tmp = lObj.builder.createFCmpOEQ(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '!==':
      tmp = lObj.builder.createFCmpUNE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '<=':
      tmp = lObj.builder.createFCmpOLE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '>=':
      tmp = lObj.builder.createFCmpOGE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '&&':
      leftValueBool = lObj.builder.createFPToSI(leftValue, i1)
      rightValueBool = lObj.builder.createFPToSI(rightValue, i1)
      tmp = lObj.builder.createAnd(leftValueBool, rightValueBool)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '||':
      leftValueBool = lObj.builder.createFPToSI(leftValue, i1)
      rightValueBool = lObj.builder.createFPToSI(rightValue, i1)
      tmp = lObj.builder.createOr(leftValueBool, rightValueBool)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    default:
      throw new Error('Unknown operator ' + operator)
  }

  return createLiteral(value, retType, lObj)
}

export { evalBinaryStatement }
