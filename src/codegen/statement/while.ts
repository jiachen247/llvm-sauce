import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'

import { evaluateExpression, evaluateStatement } from '../codegen'

function evalWhileStatement(node: es.WhileStatement, parent: Environment, lObj: LLVMObjs) {
  const predicateBlock = l.BasicBlock.create(lObj.context, 'while.test', lObj.function!)
  const bodyBlock = l.BasicBlock.create(lObj.context, 'while.body', lObj.function!)
  const endBlock = l.BasicBlock.create(lObj.context, 'while.end', lObj.function!)

  lObj.builder.createBr(predicateBlock)
  lObj.builder.setInsertionPoint(predicateBlock)

  const testResult = evaluateExpression(node.test, parent, lObj)

  const literalStruct = lObj.module.getTypeByName('literal')!
  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const testResultValueAddress = lObj.builder.createInBoundsGEP(literalStruct, testResult, [
    zero,
    one
  ])

  const value = lObj.builder.createLoad(testResultValueAddress)
  const asInt = lObj.builder.createFPToSI(value, l.Type.getInt1Ty(lObj.context))

  lObj.builder.createCondBr(asInt, bodyBlock, endBlock)

  lObj.builder.setInsertionPoint(bodyBlock)
  evaluateStatement(node.body, parent, lObj)

  if (!lObj.builder.getInsertBlock()!.getTerminator()) {
    lObj.builder.createBr(predicateBlock)
  }

  lObj.builder.setInsertionPoint(endBlock)
}

export { evalWhileStatement }
