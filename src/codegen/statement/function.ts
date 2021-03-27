import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { NUMBER_TYPE_CODE } from '../constants'
import { createLiteral } from '../expression/literal'
import { createNewFunctionEnvironment, getNumberTypeCode } from '../helper'
import { evalBlockStatement } from '../statement/block'

function formatFunctionName(name: string) {
  return `__${name}`
}

function evalFunctionStatement(
  node: es.FunctionDeclaration,
  parent: Environment,
  lObj: LLVMObjs
) {
  const insertPoint = lObj.builder.getInsertBlock()!

  const literalStruct = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStruct, 0)

  const numberOfParameters = node.params.length + 1 // +1 for parent env
  let argDef = []

  for (let i = 0; i < numberOfParameters; i++) {
    argDef.push(literalStructPtr)
  }

  const functionDef = l.FunctionType.get(literalStructPtr, argDef, false)

  const fun = l.Function.create(
    functionDef,
    l.LinkageTypes.ExternalLinkage,
    formatFunctionName(node.id!.name),
    lObj.module
  )

  const entry = l.BasicBlock.create(lObj.context, 'f.entry', fun)
  lObj.builder.setInsertionPoint(entry)

  const parentAddress = fun.getArguments()[0]! // first arg
  const env = createNewFunctionEnvironment(node.body.body, parent, parentAddress, lObj)

  // TODO LOAD ARGUEMENTS INTO NEW ENV

  evalBlockStatement(node.body, env, lObj)
  const one = l.ConstantFP.get(lObj.context, 1)
  const null1 = createLiteral(one, getNumberTypeCode(lObj), lObj)

  lObj.builder.createRet(null1) // dont know if this is allowed

  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(lObj.module.print())
    throw e
  }

  
  lObj.builder.setInsertionPoint(insertPoint)
}

// function buildFunctionProlog() {

// }

// function compileFunction() {

// }

export { evalFunctionStatement, formatFunctionName }
