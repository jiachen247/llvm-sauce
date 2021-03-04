import * as l from 'llvm-node'

// This is simply one object that carries all the LLVM globals around
interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  trueStr?: l.Value // strings for representation of boolean true, i.e. "true"
  falseStr?: l.Value // "false"
}

export { LLVMObjs }
