import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../context/environment'
import { LLVMObjs } from '../types/types'
import { createUndefinedLiteral } from './expression/literal'
import { evalCallExpression } from './expression/call'

import { evaluateExpression } from './codegen'
import { evalExpressionStatement } from './statement/expression'

const DELIMETER = '#'

function findAndMarkTailCalls(expr: es.Expression, currentFunctionName: string): boolean {
  if (expr.type === 'CallExpression') {
    const call = expr as es.CallExpression

    if (call.callee.type === 'Identifier') {
      const id = call.callee as es.Identifier
      if (id.name === currentFunctionName) {
        id.name = DELIMETER + id.name
        return true
      }
    }
  } else if (expr.type === 'ConditionalExpression') {
    const tenary = expr as es.ConditionalExpression
    return (
      findAndMarkTailCalls(tenary.consequent, currentFunctionName) ||
      findAndMarkTailCalls(tenary.alternate, currentFunctionName)
    )
  }

  return false
}

export { findAndMarkTailCalls }
