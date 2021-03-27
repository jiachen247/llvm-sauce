import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { createNewEnvironment } from '../helper'
import { evaluateStatement } from '../codegen'

function evalBlockStatement(node: es.Node, parent: Environment, lObj: LLVMObjs) {
  const body = (node as es.BlockStatement).body

  const env = createNewEnvironment(body, parent, lObj)

  body.map(x => evaluateStatement(x, env, lObj))
}

export { evalBlockStatement }
