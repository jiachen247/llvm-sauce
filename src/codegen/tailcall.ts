import * as es from 'estree'

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

    const consequent = findAndMarkTailCalls(tenary.consequent, currentFunctionName)
    const alternative = findAndMarkTailCalls(tenary.alternate, currentFunctionName)
    return consequent && alternative
  }

  return false
}

export { findAndMarkTailCalls }
