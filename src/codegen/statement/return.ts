import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createUndefinedLiteral } from '../expression/literal'
import { evalCallExpression } from '../expression/call'

import { evaluateExpression } from '../codegen'
import { evalExpressionStatement } from './expression'

function isTailCallRecursive(expr?: es.Expression, currentFunctionName?: string) {
  if (!expr || !currentFunctionName) {
    return false
  }

  if (expr.type === 'CallExpression' && (expr as es.CallExpression).callee.type === 'Identifier') {
    return ((expr as es.CallExpression).callee as es.Identifier).name === currentFunctionName
  }

  // // check if tenary and if either side is
  // if (expr.type === 'ConditionalExpression') {
  //   const tenary = expr as es.ConditionalExpression

  //   if (
  //     tenary.alternate.type === 'CallExpression' &&
  //     (tenary.alternate as es.CallExpression).callee.type === 'Identifier'
  //   ) {
  //     return (
  //       ((tenary.alternate as es.CallExpression).callee as es.Identifier).name ===
  //       currentFunctionName
  //     )
  //   } else if (
  //     tenary.consequent.type === 'CallExpression' &&
  //     (tenary.consequent as es.CallExpression).callee.type === 'Identifier'
  //   ) {
  //     return (
  //       ((tenary.consequent as es.CallExpression).callee as es.Identifier).name ===
  //       currentFunctionName
  //     )
  //   }
  // }

  return false
}

function evalReturnStatement(node: es.ReturnStatement, env: Environment, lObj: LLVMObjs) {
  if (node.argument) {
    if (isTailCallRecursive(node.argument, lObj.functionName)) {
      evalCallExpression(node.argument! as es.CallExpression, env, lObj, true)
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
