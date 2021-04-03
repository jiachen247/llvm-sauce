import * as es from 'estree'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createUndefinedLiteral } from '../expression/literal'
import { evaluateExpression } from '../codegen'
import { findAndMarkTailCalls } from '../tailcall'

function evalReturnStatement(node: es.ReturnStatement, env: Environment, lObj: LLVMObjs) {
  if (node.argument) {
    if (lObj.config.tco && findAndMarkTailCalls(node.argument!, lObj.functionContext.name!)) {
      const result = evaluateExpression(node.argument!, env, lObj)
      if (!lObj.builder.getInsertBlock()!.getTerminator()) {
        lObj.builder.createRet(result)
      }
      return result
    } else {
      const result = evaluateExpression(node.argument!, env, lObj)
      lObj.builder.createRet(result)
      return result
    }
  } else {
    const undef = createUndefinedLiteral(lObj)
    lObj.builder.createRet(undef)
    return undef
  }
}

export { evalReturnStatement }
