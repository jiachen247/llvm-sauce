import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, TypeRecord } from '../context/environment'
import { buildRuntime } from './runtime'
import { LLVMObjs } from '../types/types'
import { BUILDER_KEYS } from '@babel/types'

let NUMBER_CODE: l.Value, BOOLEAN_CODE: l.Value, STRING_CODE: l.Value

function malloc(size: number, lObj: LLVMObjs, name?: string) {
  const sizeValue = l.ConstantInt.get(lObj.context, size, 64)

  const mallocFunType = l.FunctionType.get(
    l.Type.getInt8PtrTy(lObj.context),
    [l.Type.getInt64Ty(lObj.context)],
    false
  )

  const mallocFun = lObj.module.getOrInsertFunction('malloc', mallocFunType)
  return lObj.builder.createCall(mallocFun.functionType, mallocFun.callee, [sizeValue], name)
}

function display(args: l.Value[], env: Environment, lObj: LLVMObjs): l.CallInst {
  // should only have one arg
  // callee: Value, args: Value[], name?: string
  // const displayFunctionType = l.FunctionType.get(
  //   l.Type.getVoidTy(lObj.context),
  //   [lObj.module.getTypeByName("literal")!], 
  //   false
  // )

  const displayFunction = lObj.module.getFunction("display")!
  if (args.length < 1) {
    console.error("display requires one arguement");
  }
  return lObj.builder.createCall(displayFunction.type.elementType, lObj.module.getFunction("display")!, args);
}

// Standard setup for a function definition.
// 1. Sets up hoist block
// 2. Sets up entry block
function functionSetup(funtype: l.FunctionType, name: string, lObj: LLVMObjs): l.Function {
  const fun = l.Function.create(funtype, l.LinkageTypes.ExternalLinkage, 'main', lObj.module)
  // The hoist block is used to hoist alloca to the top.
  const hoist = l.BasicBlock.create(lObj.context, 'hoist', fun)
  const entry = l.BasicBlock.create(lObj.context, 'entry', fun)
  lObj.builder.setInsertionPoint(entry)
  return fun
}

// Standard teardown for a function definition.
// 1. Creates unconditional branch from hoist to next block.
// 2. Adds return instruction on last block.
function functionTeardown(fun: l.Function, lObj: LLVMObjs): void {
  let bbs = fun.getBasicBlocks()
  lObj.builder.setInsertionPoint(bbs[0])
  lObj.builder.createBr(bbs[1])
  lObj.builder.setInsertionPoint(bbs[bbs.length - 1])
  lObj.builder.createRetVoid()
  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(lObj.module.print())
    throw e
  }
}

function scanOutDir(nodes: Array<es.Node>, env: Environment): number {
  let count = 0

  for (let node of nodes) {
    if (node.type === 'VariableDeclaration') {
      count += 1
      const decl = (node as es.VariableDeclaration).declarations[0]
      const id = decl.id
      let name: string | undefined
      if (id.type === 'Identifier') name = id.name

      env.addRecord(name!, count)
    }
  }
  return count
}

function createEnv(count: number, lObj: LLVMObjs): l.Value {
  const size = (count + 1) * 8 // 64 bit
  return malloc(size, lObj, 'env')
}

// Sets up the environment. This is only called once at the start.
function evalProgramExpression(node: es.Program, parent: Environment, lObj: LLVMObjs): l.Value {
  const voidFunType = l.FunctionType.get(l.Type.getVoidTy(lObj.context), false)
  const mainFun = functionSetup(voidFunType, 'main', lObj)

  // can only be declared in a function

  const env = Environment.createNewEnvironment(parent)
  const environmentSize = scanOutDir(node.body, env)
  const envValue = createEnv(environmentSize, lObj)

  env.setParent(parent)
  env.setFrame(envValue)

  node.body.map(x => evaluate(x, env, lObj))
  functionTeardown(mainFun, lObj)
  return mainFun
}

function evalIdentifierExpression(node: es.Identifier, env: Environment, lObj: LLVMObjs): l.Value {
  const v = env.get(node.name)
  if (v) return lObj.builder.createLoad(v.value!)
  // !!
  else throw new Error('Cannot find name ' + node.name)
}

function evalExpressionStatement(
  node: es.ExpressionStatement,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  const expr = node.expression
  return evaluate(expr, env, lObj)
}

function evalBinaryStatement(
  node: es.BinaryExpression | es.LogicalExpression,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  const lhs = evaluate(node.left, env, lObj)
  const rhs = evaluate(node.right, env, lObj)
  const left = lhs.type.isPointerTy() ? lObj.builder.createLoad(lhs) : lhs
  const right = rhs.type.isPointerTy() ? lObj.builder.createLoad(rhs) : rhs
  const operator = node.operator
  switch (operator) {
    case '+':
      // It is a hack. We do not have int arrays. All numbers are double.
      // Therefore we just assume int implies char. If we get an int array we
      // do concatenation. We can consider a tagged data structure in the
      // future.
      // TODO IMPLEMENT
      if (
        left.type.isPointerTy() &&
        right.type.isPointerTy() &&
        left.type.elementType.isArrayTy() &&
        right.type.elementType.isArrayTy()
      ) {
        let lt = left.type.elementType as l.ArrayType
        let rt = right.type.elementType as l.ArrayType
        if (lt.elementType.isIntegerTy() && rt.elementType.isIntegerTy()) {
          const llen = lt.numElements
          const rlen = rt.numElements
        }
      }
      return lObj.builder.createFAdd(left, right)
    case '-':
      return lObj.builder.createFSub(left, right)
    case '*':
      return lObj.builder.createFMul(left, right)
    case '/':
      return lObj.builder.createFDiv(left, right)
    case '<':
      return lObj.builder.createFCmpOLT(left, right)
    case '>':
      return lObj.builder.createFCmpOGT(left, right)
    case '===':
      return lObj.builder.createFCmpOEQ(left, right)
    case '<=':
      return lObj.builder.createFCmpOLE(left, right)
    case '>=':
      return lObj.builder.createFCmpOGE(left, right)
    case '&&':
      return lObj.builder.createAnd(left, right)
    case '||':
      return lObj.builder.createOr(left, right)
    default:
      throw new Error('Unknown operator ' + operator)
  }
}

function evalUnaryExpression(node: es.UnaryExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const operator = node.operator
  const arg = evaluate(node.argument, env, lObj)
  const val = arg.type.isPointerTy() ? lObj.builder.createLoad(arg) : arg
  switch (operator) {
    case '!':
      return lObj.builder.createNot(val)
    default:
      throw new Error('Unknown operator ' + operator)
  }
}

/*
literal
-----------------
| double: type  |
| double: value |
-----------------
*/
function evalLiteralExpression(node: es.Literal, env: Environment, lObj: LLVMObjs): l.Value {
  let value = node.value
  // malloc 16 bytes
  // write type to offset 0
  // wirte data to offset 16

  const raw: l.Value = malloc(16, lObj)
  const literalStruct = l.PointerType.get(lObj.module.getTypeByName('literal')!, 0)
  const block = lObj.builder.createBitCast(raw, literalStruct)

  switch (typeof value) {
    case 'string':
      // todo figure string out!!

      // return lObj.builder.createGlobalStringPtr(value, 'str')
      //   const actualString = lObj.builder.createGlobalStringPtr(value)
      //   // lObj.builder.create
      //   // const stringTypePtr = lObj.builder.createBitCast(block, l.Type.getDoublePtrTy(lObj.context))
      //   const stringValuePtr = lObj.builder.createInBoundsGEP(block, [
      //     l.ConstantInt.get(lObj.context, 0),
      //     l.ConstantInt.get(lObj.context, 1)
      //   ])
      //   const casted = lObj.builder.createBitCast(stringValuePtr, l.PointerType.get(l.Type.getInt8Ty(lObj.context), 0))
      //   // const casted = lObj.builder.createBitCast(stringValuePtr, l.PointerType.get(
      //   //   l.ArrayType.get(l.Type.getInt8Ty(lObj.context), 4), 0)
      //   // )
      //   lObj.builder.createStore(actualString, casted, false)
      //   // lObj.builder.createStore(STRING_CODE, stringTypePtr, false)
      break
    case 'number':
      const actualValue = l.ConstantFP.get(lObj.context, value)
      // const typePtr = lObj.builder.createBitCast(block, l.Type.getDoublePtrTy(lObj.context))
      const typePtr = lObj.builder.createInBoundsGEP(block, [
        l.ConstantInt.get(lObj.context, 0),
        l.ConstantInt.get(lObj.context, 0)
      ])
      const valuePtr = lObj.builder.createInBoundsGEP(block, [
        l.ConstantInt.get(lObj.context, 0),
        l.ConstantInt.get(lObj.context, 1)
      ])

      lObj.builder.createStore(actualValue, valuePtr, true)
      lObj.builder.createStore(NUMBER_CODE, typePtr, true)
      break
    case 'boolean':
      const boolValue = value
        ? l.ConstantFP.get(lObj.context, 0)
        : l.ConstantFP.get(lObj.context, 0)
      const boolTypePtr = lObj.builder.createBitCast(block, l.Type.getDoublePtrTy(lObj.context))
      const valueBoolPtr = lObj.builder.createInBoundsGEP(block, [
        l.ConstantInt.get(lObj.context, 0),
        l.ConstantInt.get(lObj.context, 1)
      ])
      lObj.builder.createStore(boolValue, valueBoolPtr, false)
      lObj.builder.createStore(BOOLEAN_CODE, boolTypePtr, false)
      break
    default:
      throw new Error('Unimplemented literal type ' + typeof value)
  }
  return block
}

function evalCallExpression(node: es.CallExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const callee = (node.callee as es.Identifier).name
  // TODO: This does not allow for expressions as args.
  const args = node.arguments.map(x => evaluate(x, env, lObj))
  const builtins: { [id: string]: () => l.CallInst } = {
    display: () => display(args, env, lObj)
  }
  const built = builtins[callee]
  let fun
  if (!built) {
    const fun = lObj.module.getFunction(callee)
    if (!fun) throw new Error('Undefined function ' + callee)
    else return lObj.builder.createCall(fun.type.elementType as l.FunctionType, fun, args)
  } else {
    return built() // a bit of that lazy evaluation
  }
}

function evalVariableDeclarationExpression(
  node: es.VariableDeclaration,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  const kind = node.kind
  if (kind !== 'const') throw new Error('We can only do const right now')
  const decl = node.declarations[0]
  const id = decl.id
  const init = decl.init
  let name: string | undefined
  let value: l.Value
  if (id.type === 'Identifier') name = id.name
  if (init) {
    value = evaluate(init, env, lObj)
  } else {
    throw new Error('Something wrong with the literal\n' + JSON.stringify(node))
  }
  if (!name) {
    throw new Error('Something wrong with the literal\n' + JSON.stringify(node))
  }
  // let type: Type =
  //   isNumber(value)
  //   ? Type.NUMBER
  //   : isBool(value)
  //   ? Type.BOOLEAN
  //   : isString(value)
  //   ? Type.STRING
  //   : Type.UNKNOWN

  // Nothing can possibly go wrong, really
  // let insertblock: l.BasicBlock = lObj.builder.getInsertBlock() as l.BasicBlock
  // let thefunction : l.Function = (insertblock.parent as l.Function)
  // lObj.builder.setInsertionPoint(thefunction.getBasicBlocks()[0])
  // let allocInst = lObj.builder.createAlloca(value.type, undefined, name)
  // lObj.builder.setInsertionPoint(insertblock)
  // lObj.builder.createStore(value, allocInst, false)
  // env.push(name, { offset: 0, value: allocInst, type }) // should not be offset 0

  const record = env.get(name)! // has to exist due to scanoutdir
  record.value = value
  return value
}

function evaluate(node: es.Node, env: Environment, lObj: LLVMObjs): l.Value {
  const jumptable = {
    Program: evalProgramExpression,
    VariableDeclaration: evalVariableDeclarationExpression,
    Identifier: evalIdentifierExpression,
    ExpressionStatement: evalExpressionStatement,
    UnaryExpression: evalUnaryExpression,
    BinaryExpression: evalBinaryStatement,
    LogicalExpression: evalBinaryStatement,
    Literal: evalLiteralExpression,
    CallExpression: evalCallExpression
  }
  const fun = jumptable[node.type]
  if (fun) return fun(node, env, lObj)

  throw new Error('Not implemented. ' + JSON.stringify(node))
}

function eval_toplevel(node: es.Node) {
  const context = new l.LLVMContext()
  const module = new l.Module('module', context)
  const builder = new l.IRBuilder(context)

  NUMBER_CODE = l.ConstantFP.get(context, 1)
  BOOLEAN_CODE = l.ConstantFP.get(context, 2)
  STRING_CODE = l.ConstantFP.get(context, 3)

  buildRuntime(context, module, builder)

  const env = new Environment(
    new Map<string, TypeRecord>(),
    new Map<string, number>(),
    new Map<any, l.Value>()
  )
  evaluate(node, env, { context, module, builder })
  
  return module
}

export { eval_toplevel }
