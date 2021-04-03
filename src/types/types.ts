import * as l from 'llvm-node'

interface Config {
  tco: boolean
}

interface FunctionContext {
  function?: l.Function
  name?: string
  env?: l.Value
  entry?: l.BasicBlock
  udef?: l.Value
}

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  config: Config
  functionContext: FunctionContext
}

export { LLVMObjs }
