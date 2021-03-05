import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, Type, TypeRecord } from '../context/environment'
import { isBool, isNumber, isString } from '../util/util'
import { LLVMObjs } from '../types/types'
import { display } from './primitives'

// Standard setup for a function definition.
// 1. Sets up hoist block
// 2. Sets up entry block
function functionSetup(funtype: l.FunctionType, name: string, lObj: LLVMObjs): l.Function {
  const fun = l.Function.create(funtype, l.LinkageTypes.ExternalLinkage, name, lObj.module)
  // The hoist block is used to hoist alloca to the top.
  const hoist = l.BasicBlock.create(lObj.context, 'hoist', fun)
  const entry = l.BasicBlock.create(lObj.context, 'entry', fun)
  lObj.builder.setInsertionPoint(entry)
  return fun
}

// Standard teardown for a function definition.
// 1. Creates unconditional branch from hoist to next block.
// 2. Adds return instruction on last block.
function functionTeardown(fun: l.Function, lObj: LLVMObjs, oldBB: l.BasicBlock): void {
  let bbs = fun.getBasicBlocks()
  lObj.builder.setInsertionPoint(bbs[0])
  lObj.builder.createBr(bbs[1])
  lObj.builder.setInsertionPoint(oldBB)
}

// Hoists an alloca instruction to the top of the function.
function functionHoist(value: l.Value, lObj: LLVMObjs) {
  // Nothing can possibly go wrong, really
  let insertblock: l.BasicBlock = lObj.builder.getInsertBlock() as l.BasicBlock
  let thefunction: l.Function = insertblock.parent as l.Function
  // Puts the alloca in the hoist block
  lObj.builder.setInsertionPoint(thefunction.getBasicBlocks()[0])
  let allocInst = lObj.builder.createAlloca(value.type, undefined, value.name)
  lObj.builder.setInsertionPoint(insertblock)
  return allocInst
}

function functionVerify(fun: l.Function, lObj: LLVMObjs) {
  try {
    l.verifyFunction(fun)
  } catch (e) {
    console.error(lObj.module.print())
    throw e
  }
}

// Sets up the environment. This is only called once at the start.
function evalProgramExpression(node: es.Program, env: Environment, lObj: LLVMObjs): l.Value {
  const voidFunType = l.FunctionType.get(l.Type.getVoidTy(lObj.context), false)
  const mainFun = functionSetup(voidFunType, 'main', lObj)
  node.body.map(x => evaluate(x, env, lObj))
  let bbs = mainFun.getBasicBlocks()
  functionTeardown(mainFun, lObj, bbs[bbs.length - 1])
  lObj.builder.createRetVoid()
  functionVerify(mainFun, lObj)
  return mainFun
}

function evalCallExpression(node: es.CallExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const callee = (node.callee as es.Identifier).name
  // TODO: This does not allow for expressions as args.
  const args = node.arguments.map(x => evaluate(x, env, lObj))
  const builtins = {
    "display": display
  }
  const built = builtins[callee]
  let fun
  if (!built) {
    fun = lObj.module.getFunction(callee)
    if (!fun) fun = env.get(callee)?.value as l.Function
    else if (!fun) throw new Error('Undefined function ' + callee)
    return lObj.builder.createCall(fun.type.elementType as l.FunctionType, fun, args)
  } else {
    return built(args, env, lObj) // a bit of that lazy evaluation
  }
}

function evalFunctionDeclaration(node: es.FunctionDeclaration, env: Environment, lObj: LLVMObjs): l.Value {
  // Slightly messy due to es overloading Identifier for params and variables.
  // We cannot simply reuse functionHoist
  function evalParams(x: l.Argument, env: Environment, fun: l.Function) {
    lObj.builder.setInsertionPoint(fun.getBasicBlocks()[0])
    let allocInst = lObj.builder.createAlloca(x.type, undefined, x.name)
    // TODO: Add a proper type
    env.add(x.name, { value: allocInst, type: Type.UNKNOWN })
    lObj.builder.setInsertionPoint(fun.getBasicBlocks()[1])
    lObj.builder.createStore(x, allocInst)
    return allocInst
  }
  const oldBB = lObj.builder.getInsertBlock() as l.BasicBlock
  let name = node.id?.name;
  const funenv = new Environment(new Map<string, TypeRecord>())
  env.setChild(funenv)
  // TODO: type inference
  const paramtypes = node.params.map(x => l.Type.getDoubleTy(lObj.context))
  const funtype = l.FunctionType.get(l.Type.getDoubleTy(lObj.context), paramtypes, false)

  const fun = functionSetup(funtype, name ? name : "anon", lObj)
  if (name)
    env.add(name, { value: fun, type: Type.FUNCTION })
  const params = fun.getArguments().map(
    (x, i) => {
      x.name = (node.params[i] as es.Identifier).name
      return evalParams(x, funenv, fun)
    }
  )
  evaluate(node.body, funenv, lObj)
  functionTeardown(fun, lObj, oldBB)
  functionVerify(fun, lObj)
  return fun
}

function evalReturnStatement(node: es.ReturnStatement, env: Environment, lObj: LLVMObjs) {
  const arg = node.argument
  if (arg) {
    const res = evaluate(arg, env, lObj)
    return lObj.builder.createRet(res)
  }
  return lObj.builder.createRetVoid()
}

function evalBlockStatement(node: es.BlockStatement, env: Environment, lObj: LLVMObjs) {
  // TODO: Check for return statements
  let v = node.body.map(x => evaluate(x, env, lObj))
  return v[node.body.length - 1]
}

function evalExpressionStatement(
  node: es.ExpressionStatement,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  const expr = node.expression
  return evaluate(expr, env, lObj)
}

function evalConditionalStatement(node: es.ConditionalExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const fun = (lObj.builder.getInsertBlock() as l.BasicBlock).parent as l.Function
  let thenbb = l.BasicBlock.create(lObj.context, 'then', fun)
  let elsebb = l.BasicBlock.create(lObj.context, 'else')
  let afterbb = l.BasicBlock.create(lObj.context, 'after_if')
  let nestedcond = node.alternate?.type === "ConditionalExpression"

  const test = evaluate(node.test, env, lObj)
  lObj.builder.createCondBr(test, thenbb, elsebb)

  fun.addBasicBlock(thenbb)
  lObj.builder.setInsertionPoint(thenbb)
  const conseq = evaluate(node.consequent, env, lObj)
  lObj.builder.createBr(afterbb)
  thenbb = lObj.builder.getInsertBlock() as l.BasicBlock

  fun.addBasicBlock(elsebb)
  lObj.builder.setInsertionPoint(elsebb)
  const altern = evaluate(node.alternate as es.ConditionalExpression, env, lObj) // slang enforces that this is defined
  lObj.builder.createBr(afterbb)
  elsebb = lObj.builder.getInsertBlock() as l.BasicBlock

  fun.addBasicBlock(afterbb)
  lObj.builder.setInsertionPoint(afterbb)

  let phi = lObj.builder.createPhi(l.Type.getDoubleTy(lObj.context), 2, "iftmp")
  phi.addIncoming(conseq, thenbb)
  if (nestedcond) {
    let bbs = fun.getBasicBlocks()
    phi.addIncoming(altern, bbs[bbs.length - 2])
  } else {
    phi.addIncoming(altern, elsebb)
  }
  return phi
}

function evalIfStatement(node: es.IfStatement, env: Environment, lObj: LLVMObjs) {
  const fun = (lObj.builder.getInsertBlock() as l.BasicBlock).parent as l.Function
  const thenbb = l.BasicBlock.create(lObj.context, 'then', fun)
  const elsebb = l.BasicBlock.create(lObj.context, 'else')
  const afterbb = l.BasicBlock.create(lObj.context, 'after_if')
  let thenterminated = false;
  let elseterminated = false;
  let nestedcond = node.alternate?.type === "IfStatement"

  const test = evaluate(node.test, env, lObj)
  lObj.builder.createCondBr(test, thenbb, elsebb)

  fun.addBasicBlock(thenbb)
  lObj.builder.setInsertionPoint(thenbb)
  const conseq = evaluate(node.consequent, env, lObj)
  if (thenbb.getTerminator()) // this is in case of return statements
    thenterminated = true
  else
    lObj.builder.createBr(afterbb)

  fun.addBasicBlock(elsebb)
  lObj.builder.setInsertionPoint(elsebb)
  const altern = evaluate(node.alternate as es.BlockStatement, env, lObj) // slang enforces that this is defined
  if (elsebb.getTerminator())
    elseterminated = true
  else
    lObj.builder.createBr(afterbb)
  if (nestedcond)
    lObj.builder.createBr(afterbb)

  if (thenterminated && elseterminated)
    return
  fun.addBasicBlock(afterbb)
  lObj.builder.setInsertionPoint(afterbb)

  return afterbb
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
    case '%':
      return lObj.builder.createFRem(left, right)
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

function evalLiteralExpression(node: es.Literal, env: Environment, lObj: LLVMObjs): l.Value {
  let value = node.value
  switch (typeof value) {
    case 'string':
      return lObj.builder.createGlobalStringPtr(value, 'str')
    /*
        const len = value.length
        const arrayType = l.ArrayType.get(l.Type.getInt32Ty(lObj.context), len)
        const elements = Array.from(value).map(x => l.ConstantInt.get(lObj.context, x.charCodeAt(0)))
        return l.ConstantArray.get(arrayType, elements)
        */
    case 'number':
      return l.ConstantFP.get(lObj.context, value)
    case 'boolean':
      return value ? l.ConstantInt.getTrue(lObj.context) : l.ConstantInt.getFalse(lObj.context)
    default:
      throw new Error('Unimplemented literal type ' + typeof value)
  }
}

function evalIdentifierExpression(node: es.Identifier, env: Environment, lObj: LLVMObjs): l.Value {
  const v = env.get(node.name)
  if (v) return lObj.builder.createLoad(v.value)
  else throw new Error('Cannot find name ' + node.name)
}

function evalVariableDeclarationExpression(
  node: es.VariableDeclaration,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
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
  let type: Type = isNumber(value)
    ? Type.NUMBER
    : isBool(value)
    ? Type.BOOLEAN
    : isString(value)
    ? Type.STRING
    : Type.UNKNOWN

  const allocInst = functionHoist(value, lObj)
  lObj.builder.createStore(value, allocInst, false)
  env.push(name, { value: allocInst, type })
  return allocInst
}

function evaluate(node: es.Node, env: Environment, lObj: LLVMObjs): l.Value {
  // This is actually not type safe.
  // There are two functions that return nothing: IfExpression, and BlockExpression
  const jumptable = {
    BinaryExpression: evalBinaryStatement,
    BlockStatement: evalBlockStatement,
    CallExpression: evalCallExpression,
    ConditionalExpression: evalConditionalStatement,
    ExpressionStatement: evalExpressionStatement,
    FunctionDeclaration: evalFunctionDeclaration,
    Identifier: evalIdentifierExpression,
    IfStatement: evalIfStatement,
    Literal: evalLiteralExpression,
    LogicalExpression: evalBinaryStatement,
    Program: evalProgramExpression,
    ReturnStatement: evalReturnStatement,
    UnaryExpression: evalUnaryExpression,
    VariableDeclaration: evalVariableDeclarationExpression
  }
  const fun = jumptable[node.type]
  if (fun) return fun(node, env, lObj)

  throw new Error('Not implemented. ' + JSON.stringify(node, undefined, 2))
}

function eval_toplevel(node: es.Node) {
  const context = new l.LLVMContext()
  const module = new l.Module('module', context)
  const builder = new l.IRBuilder(context)
  const env = new Environment(new Map<string, TypeRecord>(), new Map<any, l.Value>())
  evaluate(node, env, { context, module, builder })
  return module
}

export { eval_toplevel }
