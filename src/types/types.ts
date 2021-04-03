import * as l from 'llvm-node'

interface WhileLoopLabels {
  test: l.BasicBlock
  body: l.BasicBlock
  end: l.BasicBlock
}

interface Config {
  tco: boolean
}

interface FunctionContext {
  function?: l.Function
  name?: string
  env?: l.Value
  entry?: l.BasicBlock
}

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  config: Config
  functionContext: FunctionContext
  loop?: WhileLoopLabels
}

export { LLVMObjs }
