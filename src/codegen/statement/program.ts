import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createNewEnvironment } from '../helper'
import { evaluateStatement } from '../codegen'

function evalProgramStatement(node: es.Program, _: Environment, lObj: LLVMObjs): l.Value {
  const mainFunType = l.FunctionType.get(l.Type.getInt32Ty(lObj.context), false)
  const mainFun = functionSetup(mainFunType, 'main', lObj)

  const programEnv = createNewEnvironment(node.body, undefined, lObj)
  lObj.functionContext = {
    function: mainFun,
    name: 'main',
    env: programEnv.getPointer()!,
    udef: undefined
  }

  for (const statement of node.body) {
    evaluateStatement(statement, programEnv, lObj)
    if (statement.type === 'ReturnStatement') {
      break
    }
  }

  if (!lObj.builder.getInsertBlock()!.getTerminator()) {
    const zero = l.ConstantInt.get(lObj.context, 0)
    lObj.builder.createRet(zero)
  }

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
