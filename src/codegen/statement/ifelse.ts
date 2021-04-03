import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'

import { evaluateExpression, evaluateStatement } from '../codegen'

function evalIfStatement(node: es.IfStatement, parent: Environment, lObj: LLVMObjs) {
  const testResult = evaluateExpression(node.test, parent, lObj)

  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const testResultValueAddress = lObj.builder.createInBoundsGEP(literalStruct, testResult, [
    zero,
    one
  ])
  const value = lObj.builder.createLoad(testResultValueAddress)
  const asInt = lObj.builder.createFPToSI(value, l.Type.getInt1Ty(lObj.context))

  const consequentBlock = l.BasicBlock.create(
    lObj.context,
    'if.true',
    lObj.functionContext.function!
  )
  const alternativeBlock = l.BasicBlock.create(
    lObj.context,
    'if.false',
    lObj.functionContext.function!
  )
  const endBlock = l.BasicBlock.create(lObj.context, 'if.end', lObj.functionContext.function!)

  lObj.builder.createCondBr(asInt, consequentBlock, alternativeBlock)

  let conTailCall = false
  let altTailCall = false

  lObj.builder.setInsertionPoint(consequentBlock)
  const consequentResult = evaluateStatement(node.consequent, parent, lObj)
  const conEndBlock = lObj.builder.getInsertBlock()!

  if (conEndBlock.getTerminator()) {
    conTailCall = true
  } else {
    lObj.builder.createBr(endBlock)
  }

  lObj.builder.setInsertionPoint(alternativeBlock)
  const alternativeResult = evaluateStatement(node.alternate!, parent, lObj)
  const altEndBlock = lObj.builder.getInsertBlock()!

  if (altEndBlock.getTerminator()) {
    altTailCall = true
  } else {
    lObj.builder.createBr(endBlock)
  }

  lObj.builder.setInsertionPoint(endBlock)

  if (conTailCall && altTailCall) {
    // should return nothing
    return value
  } else if (conTailCall) {
    return alternativeResult
  } else if (altTailCall) {
    return consequentResult
  } else {
    const phi = lObj.builder.createPhi(literalStructPtr, 2)
    phi.addIncoming(consequentResult, conEndBlock)
    phi.addIncoming(alternativeResult, altEndBlock)
    return phi
  }
}

export { evalIfStatement }
