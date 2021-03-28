import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import {
  getNumberTypeCode,
  getBooleanTypeCode,
  getStringTypeCode,
  throwRuntimeTypeError
} from '../helper'
import { createLiteral, createStringLiteral } from './literal'
import { evaluateExpression } from '../codegen'

function typecheck(
  expectedLeftType: l.Value,
  expectedRightType: l.Value,
  actualLeftType: l.Value,
  actualRightType: l.Value,
  lObj: LLVMObjs
) {
  const next = l.BasicBlock.create(lObj.context, 'tc.next', lObj.function!)
  const error = l.BasicBlock.create(lObj.context, 'tc.error', lObj.function!)
  const valid = l.BasicBlock.create(lObj.context, 'tc.valid', lObj.function!)

  const leftMatch = lObj.builder.createFCmpOEQ(actualLeftType, expectedLeftType)
  lObj.builder.createCondBr(leftMatch, next, error)

  // next
  lObj.builder.setInsertionPoint(next)
  const rightMatch = lObj.builder.createFCmpOEQ(actualRightType, expectedRightType)

  lObj.builder.createCondBr(rightMatch, valid, error)

  // error
  lObj.builder.setInsertionPoint(error)
  throwRuntimeTypeError(lObj)
  lObj.builder.createBr(valid) // will never get there!

  lObj.builder.setInsertionPoint(valid)
}

function evalBinaryStatement(
  node: es.BinaryExpression | es.LogicalExpression,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
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
  let leftValue = lObj.builder.createLoad(left)
  let rightValue = lObj.builder.createLoad(right)

  const intType = l.Type.getInt64Ty(lObj.context)
  const i1 = l.Type.getInt1Ty(lObj.context)
  const i8ptr = l.Type.getInt8PtrTy(lObj.context)
  const doubleType = l.Type.getDoubleTy(lObj.context)

  // typecheck
  const lefType = lObj.builder.createInBoundsGEP(literalStruct, lhs, [zero, zero])
  const rightType = lObj.builder.createInBoundsGEP(literalStruct, rhs, [zero, zero])
  const leftTypeValue = lObj.builder.createLoad(lefType)
  const rightTypeValue = lObj.builder.createLoad(rightType)

  const operator = node.operator
  let value, retType, tmp, leftValueBool, rightValueBool
  switch (operator) {
    case '+':
      let res
      const firstNumberBlock = l.BasicBlock.create(lObj.context, 'add.num1', lObj.function)
      const checkFirstStirng = l.BasicBlock.create(lObj.context, 'add.cstr1', lObj.function)
      const checkSecondStirng = l.BasicBlock.create(lObj.context, 'add.cstr2', lObj.function)
      const errorBlock = l.BasicBlock.create(lObj.context, 'add.err', lObj.function)

      const numAddBlock = l.BasicBlock.create(lObj.context, 'add.num', lObj.function)
      const strcatBlock = l.BasicBlock.create(lObj.context, 'add.str', lObj.function)
      const endBlock = l.BasicBlock.create(lObj.context, 'add.end', lObj.function)

      res = lObj.builder.createFCmpOEQ(leftTypeValue, NUMBER_CODE)

      lObj.builder.createCondBr(res, firstNumberBlock, checkFirstStirng)

      lObj.builder.setInsertionPoint(firstNumberBlock)
      res = lObj.builder.createFCmpOEQ(rightTypeValue, NUMBER_CODE)
      lObj.builder.createCondBr(res, numAddBlock, errorBlock)

      lObj.builder.setInsertionPoint(checkFirstStirng)
      res = lObj.builder.createFCmpOEQ(leftTypeValue, STRING_CODE)
      lObj.builder.createCondBr(res, checkSecondStirng, errorBlock)

      lObj.builder.setInsertionPoint(checkSecondStirng)
      res = lObj.builder.createFCmpOEQ(rightTypeValue, STRING_CODE)
      lObj.builder.createCondBr(res, strcatBlock, errorBlock)

      lObj.builder.setInsertionPoint(errorBlock)
      throwRuntimeTypeError(lObj)
      lObj.builder.createBr(numAddBlock) // will never get there!

      /* ADD NUMBERS */
      lObj.builder.setInsertionPoint(numAddBlock)
      leftValue = lObj.builder.createLoad(left)
      rightValue = lObj.builder.createLoad(right)
      const valNum = lObj.builder.createFAdd(leftValue, rightValue)
      const valNumNode = createLiteral(valNum, NUMBER_CODE, lObj)
      lObj.builder.createBr(endBlock)

      /* ADD STRINGS */
      lObj.builder.setInsertionPoint(strcatBlock)
      const stringLiteral = lObj.module.getTypeByName('string_literal')!
      const stringLiteralPtr = l.PointerType.get(stringLiteral, 0)
      const strLit1 = lObj.builder.createBitCast(lhs, stringLiteralPtr)
      const strLit2 = lObj.builder.createBitCast(rhs, stringLiteralPtr)
      const lit1 = lObj.builder.createInBoundsGEP(stringLiteral, strLit1, [zero, one])
      const lit2 = lObj.builder.createInBoundsGEP(stringLiteral, strLit2, [zero, one])
      const litval1 = lObj.builder.createLoad(lit1)
      const litval2 = lObj.builder.createLoad(lit2)

      const stringConcatFunction = l.FunctionType.get(i8ptr, [i8ptr, i8ptr], false)

      const strconcat = lObj.module.getOrInsertFunction('strconcat', stringConcatFunction)
      const newString = lObj.builder.createCall(strconcat.functionType, strconcat.callee, [
        litval1,
        litval2
      ])
      const broken = createStringLiteral(newString, lObj)

      lObj.builder.createBr(endBlock)

      lObj.builder.setInsertionPoint(endBlock)
      const phi = lObj.builder.createPhi(literalStructPtr, 2)
      phi.addIncoming(valNumNode, numAddBlock)
      phi.addIncoming(broken, strcatBlock)
      return phi
    case '-':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      value = lObj.builder.createFSub(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '*':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      value = lObj.builder.createFMul(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '/':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      value = lObj.builder.createFDiv(leftValue, rightValue)
      retType = NUMBER_CODE
      break
    case '%':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      const l1 = lObj.builder.createFPToSI(leftValue, intType)
      const r1 = lObj.builder.createFPToSI(rightValue, intType)
      const v = lObj.builder.createSRem(l1, r1)
      value = lObj.builder.createSIToFP(v, doubleType)
      retType = NUMBER_CODE
      break
    case '<':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      tmp = lObj.builder.createFCmpOLT(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '>':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      tmp = lObj.builder.createFCmpOGT(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '===':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      tmp = lObj.builder.createFCmpOEQ(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '!==':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      tmp = lObj.builder.createFCmpUNE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '<=':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      tmp = lObj.builder.createFCmpOLE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '>=':
      typecheck(NUMBER_CODE, NUMBER_CODE, leftTypeValue, rightTypeValue, lObj)
      tmp = lObj.builder.createFCmpOGE(leftValue, rightValue)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '&&':
      typecheck(BOOLEAN_CODE, BOOLEAN_CODE, leftTypeValue, rightTypeValue, lObj)
      leftValueBool = lObj.builder.createFPToSI(leftValue, i1)
      rightValueBool = lObj.builder.createFPToSI(rightValue, i1)
      tmp = lObj.builder.createAnd(leftValueBool, rightValueBool)
      value = lObj.builder.createUIToFP(tmp, doubleType)
      retType = BOOLEAN_CODE
      break
    case '||':
      typecheck(BOOLEAN_CODE, BOOLEAN_CODE, leftTypeValue, rightTypeValue, lObj)
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
