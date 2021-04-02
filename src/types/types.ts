import * as l from 'llvm-node'

interface WhileLoopLabels {
  test: l.BasicBlock
  body: l.BasicBlock
  end: l.BasicBlock
}

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  function?: l.Function // current function
  functionName?: string
  functionEntry?: l.BasicBlock
  functionEnv?: l.Value
  loop?: WhileLoopLabels
}

export { LLVMObjs }
