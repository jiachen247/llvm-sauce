import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createUndefinedLiteral } from '../expression/literal'
import { evalCallExpression } from '../expression/call'

import { evaluateExpression } from '../codegen'
import { evalExpressionStatement } from './expression'

import { findAndMarkTailCalls } from '../tailcall'

function evalReturnStatement(node: es.ReturnStatement, env: Environment, lObj: LLVMObjs) {
  if (node.argument) {
    if (lObj.config.tco && findAndMarkTailCalls(node.argument!, lObj.functionContext.name!)) {
      const result = evaluateExpression(node.argument!, env, lObj)
      if (!lObj.builder.getInsertBlock()!.getTerminator()) {
        lObj.builder.createRet(result)
      }
    } else {
      const result = evaluateExpression(node.argument!, env, lObj)
      lObj.builder.createRet(result)
    }
  } else {
    const undef = createUndefinedLiteral(lObj)
    lObj.builder.createRet(undef)
  }
}

export { evalReturnStatement }
