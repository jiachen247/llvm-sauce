import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createUndefinedLiteral } from '../expression/literal'

import { evaluateExpression, evaluateStatement } from '../codegen'

function evalReturnStatement(node: es.ReturnStatement, env: Environment, lObj: LLVMObjs) {
  const result = node.argument
    ? evaluateExpression(node.argument, env, lObj)
    : createUndefinedLiteral(lObj)

  lObj.builder.createRet(result)
}

export { evalReturnStatement }
