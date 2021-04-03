import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createNewEnvironment } from '../helper'
import { evaluateStatement } from '../codegen'
import { createUndefinedLiteral } from '../expression/literal'

function evalBlockStatement(node: es.Node, parent: Environment, lObj: LLVMObjs): l.Value {
  const body = (node as es.BlockStatement).body

  const env = createNewEnvironment(body, parent, lObj)
  let last = createUndefinedLiteral(lObj)

  for (const statement of body) {
    last = evaluateStatement(statement, env, lObj)
    if (statement.type === 'ReturnStatement') {
      return last
    }
  }

  return last
}

export { evalBlockStatement }
