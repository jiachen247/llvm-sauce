import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'

import { evaluateExpression, evaluateStatement } from '../codegen'

function evalIfStatement(node: es.IfStatement, parent: Environment, lObj: LLVMObjs) {
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

  const consequentBlock = l.BasicBlock.create(lObj.context, 'if.true', lObj.function!)
  const alternativeBlock = l.BasicBlock.create(lObj.context, 'if.false', lObj.function!)
  const endBlock = l.BasicBlock.create(lObj.context, 'if.end', lObj.function!)

  lObj.builder.createCondBr(asInt, consequentBlock, alternativeBlock)

  lObj.builder.setInsertionPoint(consequentBlock)
  evaluateStatement(node.consequent, parent, lObj)
  lObj.builder.createBr(endBlock)

  lObj.builder.setInsertionPoint(alternativeBlock)
  evaluateStatement(node.alternate!, parent, lObj)
  lObj.builder.createBr(endBlock)

  lObj.builder.setInsertionPoint(endBlock)
}

export { evalIfStatement }
