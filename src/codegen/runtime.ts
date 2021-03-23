import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, TypeRecord } from '../context/environment'
import { LLVMObjs } from '../types/types'
import { display } from './primitives'

function buildDisplayFunction(context: l.LLVMContext, module: l.Module, builder: l.IRBuilder) {
  // for now can just print out struct
  const displayFunctionType = l.FunctionType.get(
    l.Type.getVoidTy(context),
    [l.PointerType.get(module.getTypeByName('literal')!, 0)],
    false
  )

  //result: Type, params: Type[], isVarArg: boolean):
  const fun = l.Function.create(
    displayFunctionType,
    l.LinkageTypes.ExternalLinkage,
    'display',
    module
  )
  const hoist = l.BasicBlock.create(context, 'hoist', fun)
  const entry = l.BasicBlock.create(context, 'entry', fun)
  builder.setInsertionPoint(entry)
  // builder.createFAdd(
  //   l.ConstantFP.get(context, 1),
  //   l.ConstantFP.get(context, 1)
  // )
  const literal = fun.getArguments()[0]!
  const typePtr = builder.createInBoundsGEP(literal, [
    l.ConstantInt.get(context, 0),
    l.ConstantInt.get(context, 0)
  ])

  const valuePtr = builder.createInBoundsGEP(literal, [
    l.ConstantInt.get(context, 0),
    l.ConstantInt.get(context, 1)
  ])

  const type = builder.createLoad(typePtr)
  const value = builder.createLoad(valuePtr)
  const format = builder.createGlobalString('node {%lf, %lf}\n', 'format_node')
  const formati8 = builder.createBitCast(format, l.Type.getInt8PtrTy(context))

  const printfFunctionType = l.FunctionType.get(
    l.Type.getInt32Ty(context),
    [l.Type.getInt8PtrTy(context)],
    true
  )
  const printf = module.getOrInsertFunction('printf', printfFunctionType)
  builder.createCall(printf.functionType, printf.callee, [formati8, type, value])

  let bbs = fun.getBasicBlocks()
  builder.setInsertionPoint(bbs[0])
  builder.createBr(bbs[1])
  builder.setInsertionPoint(bbs[bbs.length - 1])
  builder.createRetVoid()
  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(module.print())
    throw e
  }
  // const type = builder.\\
}

function buildRuntime(context: l.LLVMContext, module: l.Module, builder: l.IRBuilder) {
  const mallocFunctionType = l.FunctionType.get(
    l.Type.getInt8PtrTy(context),
    [l.Type.getInt64Ty(context)],
    false
  )
  // Delare abi / os functions
  // malloc - declare i8* @malloc(i64) #1
  module.getOrInsertFunction('malloc', mallocFunctionType)

  // declare printf
  const argstype = [l.Type.getInt8PtrTy(context)]
  const funtype = l.FunctionType.get(l.Type.getInt32Ty(context), argstype, true)
  module.getOrInsertFunction('printf', funtype)

  // decalre format strings
  // builder.createGlobalStringPtr("%d", "format_number")
  // builder.createGlobalStringPtr("true", "format_true")
  // builder.createGlobalStringPtr("false", "format_false")
  // builder.createGlobalStringPtr("%s", "format_string")
  // builder.createGlobalStringPtr("error: %s", "format_error")

  const structType = l.StructType.create(context, 'literal')
  // Type followed by value
  structType.setBody([l.Type.getDoubleTy(context), l.Type.getDoubleTy(context)])

  // declare display
  buildDisplayFunction(context, module, builder)
}

export { buildRuntime }
