import * as l from 'llvm-node'

interface WhileLoopLabels {
  test: l.BasicBlock,
  body: l.BasicBlock,
  end: l.BasicBlock
}

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  function?: l.Function // current function
  loop?: WhileLoopLabels
}

export { LLVMObjs }
