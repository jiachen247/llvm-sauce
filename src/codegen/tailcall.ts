import * as es from 'estree'
import { display } from './helper'

const DELIMETER = '#'

function statementContainTailCalls(statement: es.Statement, functionName: string): boolean {
  if (statement.type === 'ReturnStatement') {
    const arg = (statement as es.ReturnStatement).argument
      if (arg) {
        if(findTailCalls(arg, functionName)) {
          return true
        }
      }
  } else if (statement.type === 'IfStatement') {
    const ifstatment = statement as es.IfStatement
      if (statementContainTailCalls(ifstatment.consequent, functionName)) {
        return true
      }else if (ifstatment.alternate && statementContainTailCalls(ifstatment.alternate, functionName)) {
        return true
      }
  } else if (statement.type === 'BlockStatement') {
    const statements: Array<es.Statement> = (statement as es.BlockStatement).body

    for (let statement of statements) {
        if (statementContainTailCalls(statement, functionName)) {
          return true
        }
    }

    
  }

  return false
}

function containTailCalls(func: es.FunctionDeclaration, functionName: string): boolean {
  let result = false

  return statementContainTailCalls(func.body, functionName)
}

function findTailCalls(expr: es.Expression, currentFunctionName: string): boolean {
  if (expr.type === 'CallExpression') {
    const call = expr as es.CallExpression

    if (call.callee.type === 'Identifier') {
      const id = call.callee as es.Identifier
      if (id.name === currentFunctionName) {
        return true
      }
    }
  } else if (expr.type === 'ConditionalExpression') {
    const tenary = expr as es.ConditionalExpression

    const consequent = findTailCalls(tenary.consequent, currentFunctionName)
    const alternative = findTailCalls(tenary.alternate, currentFunctionName)
    return consequent || alternative
  }

  return false
}

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
    return consequent || alternative
  }

  return false
}

export { findAndMarkTailCalls, containTailCalls }
