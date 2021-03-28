import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createNewEnvironment } from '../helper'
import { evaluateStatement } from '../codegen'

function evalProgramStatement(node: es.Program, _: Environment, lObj: LLVMObjs): l.Value {
  const voidFunType = l.FunctionType.get(l.Type.getVoidTy(lObj.context), false)
  const mainFun = functionSetup(voidFunType, 'main', lObj)
  lObj.function = mainFun

  const programEnv = createNewEnvironment(node.body, undefined, lObj)

  node.body.map(x => evaluateStatement(x, programEnv, lObj))

  lObj.builder.createRetVoid()
  // functionTeardown(mainFun, lObj)
  try {
    l.verifyFunction(mainFun)
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
