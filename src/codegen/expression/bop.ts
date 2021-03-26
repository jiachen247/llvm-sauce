import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import {
  getNumberTypeCode,
  getBooleanTypeCode,
  getStringTypeCode,
  mallocByValue,
  display
} from '../helper'
import { createLiteral, createStringLiteral } from './literal'
import { evaluateExpression } from '../codegen'
import { STRING_TYPE_CODE } from '../constants'

// function joinStrings(s1: l.Value, s2: l.Value): l.Value {

// }

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
  const one64 = l.ConstantInt.get(lObj.context, 1, 64)
  const onefp = l.ConstantFP.get(lObj.context, 1)

  const left = lObj.builder.createInBoundsGEP(literalStruct, lhs, [zero, one])
  const right = lObj.builder.createInBoundsGEP(literalStruct, rhs, [zero, one])

  const intType = l.Type.getInt64Ty(lObj.context)
  const i1 = l.Type.getInt1Ty(lObj.context)
  const i64 = l.Type.getInt64Ty(lObj.context)
  const doubleType = l.Type.getDoubleTy(lObj.context)

  let leftValue, rightValue

  // should we do runtime type checks?
  // how to throw error?
  // should refractor
  const operator = node.operator
  let value, retType, tmp, leftValueBool, rightValueBool
  switch (operator) {
    case '+':
      // overload string concat
      const numAddBlock = l.BasicBlock.create(lObj.context, 'add.num', lObj.function)
      const strcatBlock = l.BasicBlock.create(lObj.context, 'add.str', lObj.function)
      const endBlock = l.BasicBlock.create(lObj.context, 'add.end', lObj.function)

      const lefType = lObj.builder.createInBoundsGEP(literalStruct, lhs, [zero, zero])
      const v1 = lObj.builder.createLoad(lefType)
      const isString = lObj.builder.createFCmpOEQ(v1, onefp)

      lObj.builder.createCondBr(isString, numAddBlock, strcatBlock)

      /* ADD NUMBERS */
      lObj.builder.setInsertionPoint(numAddBlock)
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      const valNum = lObj.builder.createFAdd(leftValue, rightValue)
      const valNumNode = createLiteral(valNum, NUMBER_CODE, lObj)
      lObj.builder.createBr(endBlock)

      /* CONCAT STRINGS */
      // strlen len both strings
      // malloc new string with enough space
      // copy new strings over
      // to refractor
      lObj.builder.setInsertionPoint(strcatBlock)
      const stringLiteral = lObj.module.getTypeByName('string_literal')!
      const stringLiteralPtr = l.PointerType.get(stringLiteral, 0)
      const strLit1 = lObj.builder.createBitCast(lhs, stringLiteralPtr)
      const strLit2 = lObj.builder.createBitCast(rhs, stringLiteralPtr)
      const lit1 = lObj.builder.createInBoundsGEP(stringLiteral, strLit1, [zero, one])
      const lit2 = lObj.builder.createInBoundsGEP(stringLiteral, strLit2, [zero, one])
      const litval1 = lObj.builder.createLoad(lit1)
      const litval2 = lObj.builder.createLoad(lit2)

      const strlenType = l.FunctionType.get(
        l.Type.getInt64Ty(lObj.context),
        [l.Type.getInt8PtrTy(lObj.context)],
        false
      )

      const strLenFun = lObj.module.getOrInsertFunction('strlen', strlenType)
      const len1 = lObj.builder.createCall(strLenFun.functionType, strLenFun.callee, [litval1])
      const len2 = lObj.builder.createCall(strLenFun.functionType, strLenFun.callee, [litval2])
      const sum = lObj.builder.createAdd(len1, len2)
      const total = lObj.builder.createAdd(sum, one64) // +1 for terminator

      const newStrLocation = mallocByValue(total, lObj)

      const strcpyType = l.FunctionType.get(
        l.Type.getInt8PtrTy(lObj.context),
        [l.Type.getInt8PtrTy(lObj.context), l.Type.getInt8PtrTy(lObj.context)],
        false
      )
      const strcpy = lObj.module.getOrInsertFunction('strcpy', strcpyType)

      // args: dest then src
      lObj.builder.createCall(strcpy.functionType, strcpy.callee, [newStrLocation, litval1])

      const strcatType = l.FunctionType.get(
        l.Type.getInt8PtrTy(lObj.context),
        [l.Type.getInt8PtrTy(lObj.context), l.Type.getInt8PtrTy(lObj.context)],
        false
      )

      const strcat = lObj.module.getOrInsertFunction('strcat', strcatType)

      lObj.builder.createCall(strcat.functionType, strcat.callee, [newStrLocation, litval2])

      const broken = createStringLiteral(newStrLocation, lObj)

      lObj.builder.createBr(endBlock)

      lObj.builder.setInsertionPoint(endBlock)
      const phi = lObj.builder.createPhi(literalStructPtr, 2)
      phi.addIncoming(valNumNode, numAddBlock)
      phi.addIncoming(broken, strcatBlock)
      return phi
    case '-':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      value = lObj.builder.createFSub(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '*':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      value = lObj.builder.createFMul(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '/':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      value = lObj.builder.createFDiv(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '%':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      const l1 = lObj.builder.createFPToSI(leftValue, intType)
      const r1 = lObj.builder.createFPToSI(rightValue, intType)
      const v = lObj.builder.createSRem(l1, r1)
      value = lObj.builder.createSIToFP(v, doubleType)
      retType = NUMBER_CODE
      break
    case '<':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      tmp = lObj.builder.createFCmpOLT(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '>':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      tmp = lObj.builder.createFCmpOGT(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '===':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      tmp = lObj.builder.createFCmpOEQ(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '!==':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      tmp = lObj.builder.createFCmpUNE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '<=':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      tmp = lObj.builder.createFCmpOLE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '>=':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      tmp = lObj.builder.createFCmpOGE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '&&':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      leftValueBool = lObj.builder.createFPToSI(leftValue, i1)
      rightValueBool = lObj.builder.createFPToSI(rightValue, i1)
      tmp = lObj.builder.createAnd(leftValueBool, rightValueBool)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '||':
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
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
