import * as l from 'llvm-node'

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  function?: l.Function // current function
}

interface Location {
  jumps: number
  offset: number
}

export { LLVMObjs, Location }
