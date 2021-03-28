import * as l from 'llvm-node'
import { FUNCTION_TYPE_CODE, UNDEFINED_TYPE_CODE } from '../codegen/constants'
import { mallocByValue } from '../codegen/helper'

/* CONCAT STRINGS */
// 1. strlen len both strings
// 2. malloc new string with enough space
// 3. copy first string over
// 4. cat second string to the back
// to refractor into a function
function buildStringConcat(context: l.LLVMContext, module: l.Module, builder: l.IRBuilder) {
  const strType = l.Type.getInt8PtrTy(context)

  const stringConcatFunction = l.FunctionType.get(strType, [strType, strType], false)

  const fun = l.Function.create(
    stringConcatFunction,
    l.LinkageTypes.ExternalLinkage,
    'strconcat',
    module
  )
  const entry = l.BasicBlock.create(context, 'entry', fun)
  builder.setInsertionPoint(entry)

  const str1 = fun.getArguments()[0]!
  const str2 = fun.getArguments()[1]!

  const strlenType = l.FunctionType.get(
    l.Type.getInt64Ty(context),
    [l.Type.getInt8PtrTy(context)],
    false
  )
  const one64 = l.ConstantInt.get(context, 1, 64)
  const strLenFun = module.getOrInsertFunction('strlen', strlenType)
  const len1 = builder.createCall(strLenFun.functionType, strLenFun.callee, [str1])
  const len2 = builder.createCall(strLenFun.functionType, strLenFun.callee, [str2])
  const sum = builder.createAdd(len1, len2)
  const total = builder.createAdd(sum, one64) // +1 for terminator

  const newStrLocation = mallocByValue(total, { context, module, builder })

  const strcpyType = l.FunctionType.get(
    l.Type.getInt8PtrTy(context),
    [l.Type.getInt8PtrTy(context), l.Type.getInt8PtrTy(context)],
    false
  )
  const strcpy = module.getOrInsertFunction('strcpy', strcpyType)

  // args: dest then src
  builder.createCall(strcpy.functionType, strcpy.callee, [newStrLocation, str1])

  const strcatType = l.FunctionType.get(
    l.Type.getInt8PtrTy(context),
    [l.Type.getInt8PtrTy(context), l.Type.getInt8PtrTy(context)],
    false
  )

  const strcat = module.getOrInsertFunction('strcat', strcatType)

  builder.createCall(strcat.functionType, strcat.callee, [newStrLocation, str2])

  builder.createRet(newStrLocation)

  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(module.print())
    throw e
  }
}

function buildErrorFunction(context: l.LLVMContext, module: l.Module, builder: l.IRBuilder) {
  /*
    function error(message) {
      // prints error message and exit processs
    }
  */

  const errorFunctionType = l.FunctionType.get(
    l.Type.getVoidTy(context),
    [l.Type.getInt8PtrTy(context)],
    false
  )

  const fun = l.Function.create(errorFunctionType, l.LinkageTypes.ExternalLinkage, 'error', module)
  const entry = l.BasicBlock.create(context, 'entry', fun)
  builder.setInsertionPoint(entry)

  const exitType = l.FunctionType.get(
    l.Type.getVoidTy(context),
    [l.Type.getInt32Ty(context)],
    false
  )

  const printfFunctionType = l.FunctionType.get(
    l.Type.getInt64Ty(context),
    [l.Type.getInt8PtrTy(context)],
    true
  )

  const format_error = builder.createGlobalStringPtr('error: "%s"\n', 'format_error')
  const exit = module.getOrInsertFunction('exit', exitType)
  const display = module.getOrInsertFunction('printf', printfFunctionType)
  const message = fun.getArguments()[0]!
  const one = l.ConstantInt.get(context, 1)

  builder.createCall(display.functionType, display.callee, [format_error, message])
  builder.createCall(exit.functionType, exit.callee, [one])

  builder.createRetVoid()

  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(module.print())
    throw e
  }
}

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
    l.Type.getInt64Ty(context),
    [l.Type.getInt8PtrTy(context)],
    true
  )

  let format
  const printf = module.getOrInsertFunction('printf', printfFunctionType)

  const entry = l.BasicBlock.create(context, 'entry', fun)
  const tmpBlock = l.BasicBlock.create(context, 'tmp', fun)
  const tmp1Block = l.BasicBlock.create(context, 'tmp1', fun)
  const tmp2Block = l.BasicBlock.create(context, 'tmp2', fun)
  const displayNumberBlock = l.BasicBlock.create(context, 'display_number', fun)
  const displayBooleanBlock = l.BasicBlock.create(context, 'display_boolean', fun)
  const printTrueBlock = l.BasicBlock.create(context, 'print_true', fun)
  const printFalseBlock = l.BasicBlock.create(context, 'print_false', fun)
  const displayStringBlock = l.BasicBlock.create(context, 'display_string', fun)
  const displayFunctionBlock = l.BasicBlock.create(context, 'display_function', fun)
  const displayUndefBlock = l.BasicBlock.create(context, 'display_undefined', fun)
  const endBlock = l.BasicBlock.create(context, 'end', fun)

  builder.setInsertionPoint(entry)

  const format_number = builder.createGlobalString('%lf\n', 'format_number')
  const format_true = builder.createGlobalString('true\n', 'format_true')
  const format_false = builder.createGlobalString('false\n', 'format_false')
  const format_string = builder.createGlobalString('"%s"\n', 'format_string')
  const format_function = builder.createGlobalString('function object\n', 'format_function')
  const format_undefined = builder.createGlobalString('undefined\n', 'format_undef')

  const zero = l.ConstantInt.get(context, 0)
  const one = l.ConstantInt.get(context, 1)
  const oneFP = l.ConstantFP.get(context, 1)

  const literal = fun.getArguments()[0]!
  const typePtr = builder.createInBoundsGEP(literal, [zero, zero])
  const valuePtr = builder.createInBoundsGEP(literal, [zero, one])

  const type = builder.createLoad(typePtr)
  const value = builder.createLoad(valuePtr)

  // can get from helper
  const NUMBER_CODE = l.ConstantFP.get(context, 1)
  const BOOLEAN_CODE = l.ConstantFP.get(context, 2)
  const STRING_CODE = l.ConstantFP.get(context, 3)
  const FUNCTION_CODE = l.ConstantFP.get(context, 4)
  const UNDEFINED_CODE = l.ConstantFP.get(context, 5)

  const isBoolean = builder.createFCmpOEQ(type, BOOLEAN_CODE)
  builder.createCondBr(isBoolean, displayBooleanBlock, tmpBlock)

  builder.setInsertionPoint(tmpBlock)
  const isString = builder.createFCmpOEQ(type, STRING_CODE)
  builder.createCondBr(isString, displayStringBlock, tmp1Block)

  builder.setInsertionPoint(tmp1Block)
  const isFunction = builder.createFCmpOEQ(type, FUNCTION_CODE)
  builder.createCondBr(isFunction, displayFunctionBlock, tmp2Block)

  builder.setInsertionPoint(tmp2Block)
  const isUndefined = builder.createFCmpOEQ(type, UNDEFINED_CODE)
  builder.createCondBr(isUndefined, displayUndefBlock, displayNumberBlock)


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
  // can cast to stringlit if this doesnt work in the future
  const str = builder.createBitCast(value, intType)
  format = builder.createBitCast(format_string, l.Type.getInt8PtrTy(context))
  builder.createCall(printf.functionType, printf.callee, [format, str])
  builder.createBr(endBlock)

  /* DISPLAY FUNCTION */
  builder.setInsertionPoint(displayFunctionBlock)
  format = builder.createBitCast(format_function, l.Type.getInt8PtrTy(context))
  builder.createCall(printf.functionType, printf.callee, [format])
  builder.createBr(endBlock)

  /* DISPLAY UNDEFINED */
  builder.setInsertionPoint(displayUndefBlock)
  format = builder.createBitCast(format_undefined, l.Type.getInt8PtrTy(context))
  builder.createCall(printf.functionType, printf.callee, [format])
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
  const funtype = l.FunctionType.get(l.Type.getInt64Ty(context), argstype, true)
  module.getOrInsertFunction('printf', funtype)

  // declare strcpy
  const strcpyType = l.FunctionType.get(
    l.Type.getInt8PtrTy(context),
    [l.Type.getInt8PtrTy(context), l.Type.getInt8PtrTy(context)],
    false
  )

  module.getOrInsertFunction('strcpy', strcpyType)

  // declare strlen
  const strlenType = l.FunctionType.get(
    l.Type.getInt64Ty(context),
    [l.Type.getInt8PtrTy(context)],
    false
  )

  module.getOrInsertFunction('strlen', strlenType)

  // declare strcat
  // declare i8* @strcat(i8*, i8*)
  const strcatType = l.FunctionType.get(
    l.Type.getInt8PtrTy(context),
    [l.Type.getInt8PtrTy(context), l.Type.getInt8PtrTy(context)],
    false
  )
  module.getOrInsertFunction('strcat', strcatType)

  // declare exit
  const exitType = l.FunctionType.get(
    l.Type.getVoidTy(context),
    [l.Type.getInt32Ty(context)],
    false
  )
  module.getOrInsertFunction('exit', exitType)

  // Type followed by value
  const structType = l.StructType.create(context, 'literal')
  structType.setBody([l.Type.getDoubleTy(context), l.Type.getDoubleTy(context)])

  // Type followed by value
  const stringLitType = l.StructType.create(context, 'string_literal')
  stringLitType.setBody([l.Type.getDoubleTy(context), l.Type.getInt8PtrTy(context)])

  const litPtr = l.PointerType.get(structType, 0)
  const litPtrPtr = l.PointerType.get(litPtr, 0)

  const genericFunctionType = l.FunctionType.get(litPtr, [litPtr, litPtrPtr], false)

  const functionLiteral = l.StructType.create(context, 'function_literal')

  functionLiteral.setBody([
    l.Type.getDoubleTy(context),
    l.PointerType.get(structType, 0), // enclosing env
    l.PointerType.get(genericFunctionType, 0) // function pointer
  ])

  // declare display
  buildDisplayFunction(context, module, builder)

  buildErrorFunction(context, module, builder)

  buildStringConcat(context, module, builder)
}

export { buildRuntime }
