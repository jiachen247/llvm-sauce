import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { evaluateExpression } from '../codegen'

function evalTernaryExpression(
  node: es.ConditionalExpression,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  const test = evaluateExpression(node.test, env, lObj)

  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)
  const zero = l.ConstantInt.get(lObj.context, 0)
  const one = l.ConstantInt.get(lObj.context, 1)

  const testResultValueAddress = lObj.builder.createInBoundsGEP(literalStruct, test, [zero, one])
  const value = lObj.builder.createLoad(testResultValueAddress)
  const asInt = lObj.builder.createFPToSI(value, l.Type.getInt1Ty(lObj.context))

  const consequentBlock = l.BasicBlock.create(lObj.context, 'tenary.true', lObj.function!)
  const alternativeBlock = l.BasicBlock.create(lObj.context, 'tenary.false', lObj.function!)
  const endBlock = l.BasicBlock.create(lObj.context, 'if.end', lObj.function!)

  lObj.builder.createCondBr(asInt, consequentBlock, alternativeBlock)

  lObj.builder.setInsertionPoint(consequentBlock)
  const consequentValue = evaluateExpression(node.consequent, env, lObj)
  const conEndBlock = lObj.builder.getInsertBlock()!
  lObj.builder.createBr(endBlock)

  lObj.builder.setInsertionPoint(alternativeBlock)
  const alternativeValue = evaluateExpression(node.alternate!, env, lObj)
  const altEndBlock = lObj.builder.getInsertBlock()!
  lObj.builder.createBr(endBlock)

  lObj.builder.setInsertionPoint(endBlock)
  const phi = lObj.builder.createPhi(literalStructPtr, 2)
  phi.addIncoming(consequentValue, conEndBlock)
  phi.addIncoming(alternativeValue, altEndBlock)
  return phi
}

export { evalTernaryExpression }
