import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createNewEnvironment, display } from '../helper'
import { evalBlockStatement } from '../statement/block'

function evalProgramStatement(node: es.Program, _: Environment, lObj: LLVMObjs): l.Value {
  const mainFunType = l.FunctionType.get(l.Type.getInt32Ty(lObj.context), false)
  const mainFun = functionSetup(mainFunType, 'main', lObj)

  const programEnv = createNewEnvironment(node.body, undefined, lObj)
  lObj.functionContext = {
    function: mainFun,
    name: 'main',
    env: programEnv,
    udef: undefined,
    phis: []
  }

  // This is guranteed to be a block
  const block = node.body[0] as es.BlockStatement

  const result = evalBlockStatement(block, programEnv, lObj)
  display([result], programEnv, lObj)

  const zero = l.ConstantInt.get(lObj.context, 0)
  lObj.builder.createRet(zero)

  try {
    l.verifyFunction(mainFun)
    l.verifyModule(lObj.module)
  } catch (e) {
    console.error(lObj.module.print())
    throw e
  }
  return mainFun
}

function functionSetup(funtype: l.FunctionType, name: string, lObj: LLVMObjs): l.Function {
  const fun = l.Function.create(funtype, l.LinkageTypes.ExternalLinkage, 'main', lObj.module)
  const entry = l.BasicBlock.create(lObj.context, 'entry', fun)
  lObj.builder.setInsertionPoint(entry)
  return fun
}

export { evalProgramStatement }
