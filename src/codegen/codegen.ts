import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, Location, Type, Record } from '../context/environment'
import { getType, getLLVMType } from '../util/util'
import { LLVMObjs } from '../types/types'
import { display, malloc } from './primitives'

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
    display: display,
    malloc: malloc
  }
  const built = builtins[callee]
  let fun
  if (!built) {
    fun = lObj.module.getFunction(callee)
    if (!fun) fun = env.get(callee)?.value as l.Function
    else if (!fun) throw new Error('Undefined function ' + callee)
    return lObj.builder.createCall(fun.type.elementType as l.FunctionType, fun, args)
  } else {
    return built(args, env, lObj)
  }
}

function evalFunctionDeclaration(
  node: es.FunctionDeclaration,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  // Loads names defined in the context to memory. This context is inherited
  // from the parent.
  function loadParentContext(env: Environment, fun: l.Function) {

    if (!env.context)
      return
    // this is needed to get around the TS type checker for some reason
    const context = env.context

    const names = env.findAllParentsNames()
    lObj.builder.setInsertionPoint(fun.getBasicBlocks()[1])
    let i = 0
    console.log(names)
    names.forEach((r, k) => {
      console.log(r)
      const ptr = lObj.builder.createInBoundsGEP(
        context,
        [
          l.ConstantInt.get(lObj.context, 0),
          l.ConstantInt.get(lObj.context, i)
        ]
      )
      env.add(k, { value: ptr, type: r.type })
      i++
    });
  }
  // Creates a context (environment frame) using the params and variables in the
  // function body
  // TODO: add a scan for variable declarations in the body!
  function createContext(env: Environment, fun: l.Function, params: l.Argument[]) {
    const types : l.Type[] = []
    params.forEach(x => {
      if (!env.get(x.name))
        env.add(x.name, { value: x, type: getType(x) })
    })
    env.names.forEach((tr: Record, key: string) => {
      // TODO: add type inference
      types.push(getLLVMType(Type.NUMBER, lObj.context))
    })

    lObj.builder.setInsertionPoint(fun.getBasicBlocks()[0])
    const structType = l.StructType.create(lObj.context, "context")
    types.push(structType)
    structType.setBody(types)
    const structPtrType = structType.getPointerTo()

    // these do: structtype* structptr = (structtype *) malloc(sizeof structtype)
    const ssize = lObj.module.dataLayout.getTypeStoreSize(structType)
    let structptr : l.Value = malloc([l.ConstantInt.get(lObj.context, ssize)], env, lObj)
    structptr = lObj.builder.createBitCast(structptr, structPtrType, "contextptr")

    let i = 0
    // these do: entrytype* ptr = structptr->entry, i.e structptr[0][entry]
    env.names.forEach((tr: Record, key: string) => {
      const ptr = lObj.builder.createInBoundsGEP(
        structptr,
        [
          l.ConstantInt.get(lObj.context, 0),
          l.ConstantInt.get(lObj.context, i)
        ],
        tr.value.name)
      env.add(key, { value: ptr, type: tr.type, funSig: tr.funSig })
      i++
    })

    params.forEach(x => {
      lObj.builder.setInsertionPoint(fun.getBasicBlocks()[1])
      const v = env.get(x.name)
      if (v)
        lObj.builder.createStore(x, v.value)
    })
    return structptr
  }

  const oldBB = lObj.builder.getInsertBlock() as l.BasicBlock
  let name = node.id?.name
  const funenv = env.createChild(Location.FUNCTION)
  // TODO: type inference
  const paramtypes = node.params.map(x => l.Type.getDoubleTy(lObj.context))
  const funtype = l.FunctionType.get(l.Type.getDoubleTy(lObj.context), paramtypes, false)

  const fun = functionSetup(funtype, name ? name : 'anon', lObj)

  if (name) env.add(name, { value: fun, type: Type.FUNCTION })
  const params = fun.getArguments().map((x, i) => {
    x.name = (node.params[i] as es.Identifier).name
    return x
    // return evalParams(x, funenv, fun)
  })
  //funenv.context = createContext(funenv, fun, params)
  //loadParentContext(funenv, fun)

  lObj.builder.setInsertionPoint(fun.getBasicBlocks()[1])
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

function evalIfStatement(
  node: es.IfStatement | es.ConditionalExpression,
  env: Environment,
  lObj: LLVMObjs
) {
  const fun = (lObj.builder.getInsertBlock() as l.BasicBlock).parent as l.Function
  const thenbb = l.BasicBlock.create(lObj.context, 'then', fun)
  const elsebb = l.BasicBlock.create(lObj.context, 'else')
  const afterbb = l.BasicBlock.create(lObj.context, 'after_if')
  let thenterminated = false
  let elseterminated = false
  // This means there is some kind of else if structure and the phi nodes need
  // to be redirected later on
  let elif =
    node.alternate?.type === 'IfStatement' || node.alternate?.type === 'ConditionalExpression'

  // TODO: add new environment
  const test = evaluate(node.test, env, lObj)
  lObj.builder.createCondBr(test, thenbb, elsebb)

  fun.addBasicBlock(thenbb)
  lObj.builder.setInsertionPoint(thenbb)
  const conseq = evaluate(node.consequent, env, lObj)
  // this is in case of return statements
  if (thenbb.getTerminator())
    thenterminated = true
  else lObj.builder.createBr(afterbb)

  fun.addBasicBlock(elsebb)
  lObj.builder.setInsertionPoint(elsebb)
  const altern = evaluate(node.alternate as es.BlockStatement, env, lObj) // slang enforces that this is defined
  if (elsebb.getTerminator()) elseterminated = true
  else lObj.builder.createBr(afterbb)

  if (thenterminated && elseterminated) return elsebb.getTerminator()

  let bbs = fun.getBasicBlocks()
  if (elif) lObj.builder.createBr(afterbb)
  fun.addBasicBlock(afterbb)
  lObj.builder.setInsertionPoint(afterbb)

  let phi = lObj.builder.createPhi(l.Type.getDoubleTy(lObj.context), 2, 'iftmp')
  phi.addIncoming(conseq, thenbb)
  // If there is elif structure we have to direct the answer of else to the phi
  // of the phi node of the parent if block
  if (elif) phi.addIncoming(altern, bbs[bbs.length - 1])
  else phi.addIncoming(altern, elsebb)

  return phi
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
  const allocInst =
    env.loc === Location.FUNCTION
      ? functionHoist(value, lObj)
      : lObj.builder.createAlloca(value.type, undefined, name)
  lObj.builder.createStore(value, allocInst, false)
  env.push(name, { value: allocInst, type: getType(value) })
  return allocInst
}

function evaluate(node: es.Node, env: Environment, lObj: LLVMObjs): l.Value {
  // This is actually not type safe.
  // There are two functions that return nothing: IfExpression, and BlockExpression
  const jumptable = {
    ArrowFunctionExpression: evalFunctionDeclaration,
    BinaryExpression: evalBinaryStatement,
    BlockStatement: evalBlockStatement,
    CallExpression: evalCallExpression,
    ConditionalExpression: evalIfStatement,
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
  const env = new Environment(
    new Map<string, Record>(),
    Location.FUNCTION,
    undefined
  )
  evaluate(node, env, { context, module, builder })
  l.verifyModule(module)
  return module
}

export { eval_toplevel }
