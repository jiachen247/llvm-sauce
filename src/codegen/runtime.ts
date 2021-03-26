import * as l from 'llvm-node'

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

  const printfFunctionType = l.FunctionType.get(
    l.Type.getInt32Ty(context),
    [l.Type.getInt8PtrTy(context)],
    true
  )

  let format
  const printf = module.getOrInsertFunction('printf', printfFunctionType)

  const entry = l.BasicBlock.create(context, 'entry', fun)
  const tmpBlock = l.BasicBlock.create(context, 'tmp', fun)
  const displayNumberBlock = l.BasicBlock.create(context, 'display_number', fun)
  const displayBooleanBlock = l.BasicBlock.create(context, 'display_boolean', fun)
  const printTrueBlock = l.BasicBlock.create(context, 'print_true', fun)
  const printFalseBlock = l.BasicBlock.create(context, 'print_false', fun)
  const displayStringBlock = l.BasicBlock.create(context, 'display_string', fun)
  const endBlock = l.BasicBlock.create(context, 'end', fun)

  builder.setInsertionPoint(entry)

  const format_number = builder.createGlobalString('%lf\n', 'format_number')
  const format_true = builder.createGlobalString('true\n', 'format_true')
  const format_false = builder.createGlobalString('false\n', 'format_false')
  const format_string = builder.createGlobalString('"%s"\n', 'format_string')
  const format_error = builder.createGlobalString('error: "%s"\n', 'format_error')

  const zero = l.ConstantInt.get(context, 0)
  const one = l.ConstantInt.get(context, 1)
  const oneFP = l.ConstantFP.get(context, 1)

  const literal = fun.getArguments()[0]!
  const typePtr = builder.createInBoundsGEP(literal, [zero, zero])
  const valuePtr = builder.createInBoundsGEP(literal, [zero, one])

  const type = builder.createLoad(typePtr)
  const value = builder.createLoad(valuePtr)

  // const NUMBER_CODE = l.ConstantFP.get(context, 1)
  const BOOLEAN_CODE = l.ConstantFP.get(context, 2)
  const STRING_CODE = l.ConstantFP.get(context, 3)

  const isBoolean = builder.createFCmpOEQ(type, BOOLEAN_CODE)
  builder.createCondBr(isBoolean, displayBooleanBlock, tmpBlock)

  builder.setInsertionPoint(tmpBlock)
  const isString = builder.createFCmpOEQ(type, STRING_CODE)
  builder.createCondBr(isString, displayStringBlock, displayNumberBlock)

  /* DISPLAY NUMBER */
  builder.setInsertionPoint(displayNumberBlock)
  format = builder.createBitCast(format_number, l.Type.getInt8PtrTy(context))
  builder.createCall(printf.functionType, printf.callee, [format, value])
  builder.createBr(endBlock)

  /* DISPLAY BOOLEAN */
  builder.setInsertionPoint(displayBooleanBlock)
  const isTrue = builder.createFCmpOEQ(value, oneFP)
  builder.createCondBr(isTrue, printTrueBlock, printFalseBlock)
  builder.setInsertionPoint(printTrueBlock)
  format = builder.createBitCast(format_true, l.Type.getInt8PtrTy(context))
  builder.createCall(printf.functionType, printf.callee, [format])
  builder.createBr(endBlock)
  builder.setInsertionPoint(printFalseBlock)
  format = builder.createBitCast(format_false, l.Type.getInt8PtrTy(context))
  builder.createCall(printf.functionType, printf.callee, [format])
  builder.createBr(endBlock)

  /* DISPLAY STRING */
  builder.setInsertionPoint(displayStringBlock)
  const intType = l.Type.getInt64Ty(context)
  const str = builder.createBitCast(value, intType)
  format = builder.createBitCast(format_string, l.Type.getInt8PtrTy(context))
  builder.createCall(printf.functionType, printf.callee, [format, str])
  builder.createBr(endBlock)

  builder.setInsertionPoint(endBlock)
  builder.createRetVoid()

  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(module.print())
    throw e
  }
}

function buildRuntime(context: l.LLVMContext, module: l.Module, builder: l.IRBuilder) {
  const mallocFunctionType = l.FunctionType.get(
    l.Type.getInt8PtrTy(context),
    [l.Type.getInt64Ty(context)],
    false
  )
  //  declare i8* @malloc(i64) #1
  module.getOrInsertFunction('malloc', mallocFunctionType)

  // declare printf
  const argstype = [l.Type.getInt8PtrTy(context)]
  const funtype = l.FunctionType.get(l.Type.getInt32Ty(context), argstype, true)
  module.getOrInsertFunction('printf', funtype)

  // declare strcat
  // declare i8* @strcat(i8*, i8*)
  // const strcatType = l.FunctionType.get(
  //   l.Type.getInt8PtrTy(context),
  //   [l.Type.getInt8PtrTy(context), l.Type.getInt8PtrTy(context)],
  //   false
  // )

  const strcatType = l.FunctionType.get(
    l.Type.getInt8PtrTy(context),
    [l.Type.getInt8PtrTy(context), l.Type.getInt8PtrTy(context)],
    false
  )
  module.getOrInsertFunction('strcat', strcatType)

  const structType = l.StructType.create(context, 'literal')
  // Type followed by value
  structType.setBody([l.Type.getDoubleTy(context), l.Type.getDoubleTy(context)])

  // declare display
  buildDisplayFunction(context, module, builder)
}

export { buildRuntime }
