import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, TypeRecord } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { lookup_env, scanOutDir, createEnv } from '../helper'
import { evaluateStatement } from '../codegen'

function evalBlockStatement(node: es.Node, parent: Environment, lObj: LLVMObjs) {
  const body = (node as es.BlockStatement).body

  const env = Environment.createNewEnvironment()
  const environmentSize = scanOutDir(body, env)
  const envValue = createEnv(environmentSize, lObj)
  // store back addr in fist addr
  const parentAddr = parent.getFrame()!
  const framePtr = lObj.builder.createBitCast(envValue, l.PointerType.get(parentAddr.type, 0))
  lObj.builder.createStore(parentAddr, framePtr)
  env.setParent(parent)
  env.setFrame(envValue)

  body.map(x => evaluateStatement(x, env, lObj))
}

export { evalBlockStatement }
