import * as l from 'llvm-node'
import { Environment } from '../context/environment'

interface Config {
  tco: boolean
}

interface FunctionContext {
  function?: l.Function
  name?: string
  env?: Environment
  entry?: l.BasicBlock
  udef?: l.Value
  phis?: Array<l.PhiNode>
}

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  config: Config
  functionContext: FunctionContext
  typeErrorString?: l.Value
}

export { LLVMObjs }
