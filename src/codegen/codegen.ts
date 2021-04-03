import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, Record } from '../context/environment'
import { buildRuntime } from '../runtime/runtime'
import { LLVMObjs } from '../types/types'
import { evalProgramStatement } from './statement/program'
import { evalVariableDeclarationExpression } from './statement/assignment'
import { evalExpressionStatement } from './statement/expression'
import { evalBlockStatement } from './statement/block'
import { evalIfStatement } from './statement/ifelse'
import { evalFunctionStatement, evalArrowFunctionExpression } from './statement/function'
import { evalReturnStatement } from './statement/return'
import { evalIdentifierExpression } from './expression/identifier'
import { evalUnaryExpression } from './expression/uop'
import { evalBinaryStatement } from './expression/bop'
import { evalLiteralExpression } from './expression/literal'
import { evalCallExpression } from './expression/call'
import { evalTernaryExpression } from './expression/ternary'

const statementHandlers = {
  Program: evalProgramStatement,
  VariableDeclaration: evalVariableDeclarationExpression,
  ExpressionStatement: evalExpressionStatement,
  BlockStatement: evalBlockStatement,
  IfStatement: evalIfStatement,
  FunctionDeclaration: evalFunctionStatement,
  ReturnStatement: evalReturnStatement
}

const expressionHandlers = {
  Identifier: evalIdentifierExpression,
  UnaryExpression: evalUnaryExpression,
  BinaryExpression: evalBinaryStatement,
  LogicalExpression: evalBinaryStatement,
  Literal: evalLiteralExpression,
  CallExpression: evalCallExpression,
  ConditionalExpression: evalTernaryExpression,
  ArrowFunctionExpression: evalArrowFunctionExpression
}

function evaluateExpression(
  node: es.Node,
  env: Environment,
  lObj: LLVMObjs,
  inReturnStatement = false
): l.Value {
  const fun = expressionHandlers[node.type]

  if (fun) {
    return fun(node, env, lObj, inReturnStatement)
  } else {
    throw new Error('Expression not implemented. ' + JSON.stringify(node))
  }
}

function evaluateStatement(node: es.Node, env: Environment, lObj: LLVMObjs) {
  const fun = statementHandlers[node.type]

  if (fun) {
    fun(node, env, lObj)
  } else {
    throw new Error('Statement not implemented. ' + JSON.stringify(node))
  }
}

function eval_toplevel(node: es.Node, tco: boolean) {
  const context = new l.LLVMContext()
  const module = new l.Module('module', context)
  const builder = new l.IRBuilder(context)

  buildRuntime(context, module, builder)

  // doesnt do anything currently
  const globalEnv = new Environment(new Map<string, Record>())
  const config = { tco }
  const functionContext = {}
  const lObj = { context, module, builder, config, functionContext }
  evaluateStatement(node, globalEnv, lObj)
  return module
}

export { eval_toplevel, evaluateExpression, evaluateStatement }
