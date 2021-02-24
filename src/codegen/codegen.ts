import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, Type, TypeRecord } from '../context/environment'

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
  trueStr?: l.Value // strings for representation of boolean true, i.e. "true"
  falseStr?: l.Value // "false"
}

function isBool(x: l.Value) {
  return x.type.isIntegerTy() && (x.type as l.IntegerType).getBitWidth() === 1
}

function isString(x: l.Value) {
  return x.type.isPointerTy() && x.name.search("str")
}

function isNumber(x: l.Value) {
  return x.type.isDoubleTy()
}

class ProgramExpression {
  static codegen(node: es.Program, env: Environment, lObj: LLVMObjs): l.Value {
    const voidFunType = l.FunctionType.get(l.Type.getVoidTy(lObj.context), false)
    const mainFun = l.Function.create(
      voidFunType,
      l.LinkageTypes.ExternalLinkage,
      'main',
      lObj.module
    )
    const entry = l.BasicBlock.create(lObj.context, 'entry', mainFun)
    lObj.builder.setInsertionPoint(entry)
    node.body.map(x => evaluate({ node: x, env, lObj }))
    lObj.builder.createRetVoid()
    try {
      l.verifyFunction(mainFun)
    } catch (e) {
      console.error(lObj.module.print())
      throw e
    }
    return mainFun
  }
}
class IndentifierExpression {
  static codegen(node: es.Identifier, env: Environment, lObj: LLVMObjs): l.Value {
    const v = env.get(node.name)
    if (v) return lObj.builder.createLoad(v.value)
    else throw new Error('Cannot find name ' + node.name)
  }
}
class Expression {
  static codegen(node: es.ExpressionStatement, env: Environment, lObj: LLVMObjs): l.Value {
    const expr = node.expression
    return evaluate({ node: expr, env, lObj })
  }
}
class BinaryExpression {
  static codegen(
    node: es.BinaryExpression | es.LogicalExpression,
    env: Environment,
    lObj: LLVMObjs
  ): l.Value {
    const lhs = evaluate({ node: node.left, env, lObj })
    const rhs = evaluate({ node: node.right, env, lObj })
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
}
class UnaryExpression {
  static codegen(node: es.UnaryExpression, env: Environment, lObj: LLVMObjs): l.Value {
    const operator = node.operator
    const arg = evaluate({ node: node.argument, env, lObj })
    const val = arg.type.isPointerTy() ? lObj.builder.createLoad(arg) : arg
    switch (operator) {
      case '!':
        return lObj.builder.createNot(val)
      default:
        throw new Error('Unknown operator ' + operator)
    }
  }
}
class LiteralExpression {
  static codegen(node: es.Literal, env: Environment, lObj: LLVMObjs): l.Value {
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
}
class CallExpression {
  static codegen(node: es.CallExpression, env: Environment, lObj: LLVMObjs): l.Value {
    const callee = (node.callee as es.Identifier).name
    // TODO: This does not allow for expressions as args.
    const args = node.arguments.map(x => evaluate({ node: x, env, lObj }))
    const builtins: { [id: string]: () => l.CallInst } = {
      display: () => CallExpression.display(args, env, lObj)
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

  // Prints number or strings. Vararg.
  static display(args: l.Value[], env: Environment, lObj: LLVMObjs) {
    function boolConv(x: l.Value): l.Value {
      // We have to do some funky business here to convert bools (0 and 1) to strings.
      // We store the strings as globals. This should be the only code to ever
      // touch these two values so this will be fine for now.
      const tConstName = 'TRUE'
      const fConstName = 'FALSE'
      let t = env.getGlobal(tConstName)
      if (t === undefined) {
        t = env.addGlobal(tConstName, lObj.builder.createGlobalStringPtr('true', 'true'))
      }
      let f = env.getGlobal(fConstName)
      if (f === undefined) {
        f = env.addGlobal(fConstName, lObj.builder.createGlobalStringPtr('false', 'false'))
      }
      return lObj.builder.createSelect(x, t, f, 'booltostr')
    }
    const fmt = args.map(x => (isNumber(x) ? '%f' : '%s')).join(' ')
    args = args.map(x =>
      isBool(x) ? boolConv(x) : x
    )
    const fmtptr = lObj.builder.createGlobalStringPtr(fmt, 'format')
    const argstype = [l.Type.getInt8PtrTy(lObj.context)]
    const funtype = l.FunctionType.get(l.Type.getInt32Ty(lObj.context), argstype, true)
    const fun = lObj.module.getOrInsertFunction('printf', funtype)
    return lObj.builder.createCall(fun.functionType, fun.callee, [fmtptr].concat(args))
  }
}
class VariableDeclarationExpression {
  static codegen(node: es.VariableDeclaration, env: Environment, lObj: LLVMObjs): l.Value {
    const kind = node.kind
    if (kind !== 'const') throw new Error('We can only do const right now')
    const builder = lObj.builder
    const decl = node.declarations[0]
    const id = decl.id
    const init = decl.init
    let name: string | undefined
    let value: l.Value
    if (id.type === 'Identifier') name = id.name
    if (init) {
      value = evaluate({ node: init, env, lObj })
    } else {
      throw new Error('Something wrong with the literal\n' + JSON.stringify(node))
    }
    if (!name) {
      throw new Error('Something wrong with the literal\n' + JSON.stringify(node))
    }
    console.log(value.type)
    let type: Type = isNumber(value) ? Type.NUMBER : isBool(value) ? Type.BOOLEAN : isString(value) ? Type.STRING : Type.UNKNOWN
    let allocInst = builder.createAlloca(value.type, undefined, name)
    builder.createStore(value, allocInst, false)
    env.push(name, { value: allocInst, type })
    return allocInst
  }
}

function evaluate({
  node,
  env,
  lObj
}: {
  node: es.Node
  env: Environment
  lObj: LLVMObjs
}): l.Value {
  switch (node.type) {
    case 'Program':
      return ProgramExpression.codegen(node, env, lObj)
    case 'VariableDeclaration':
      return VariableDeclarationExpression.codegen(node, env, lObj)
    case 'Identifier':
      return IndentifierExpression.codegen(node, env, lObj)
    case 'ExpressionStatement':
      return Expression.codegen(node, env, lObj)
    case 'UnaryExpression':
      return UnaryExpression.codegen(node, env, lObj)
    case 'LogicalExpression':
      return BinaryExpression.codegen(node, env, lObj)
    case 'BinaryExpression':
      return BinaryExpression.codegen(node, env, lObj)
    case 'Literal':
      return LiteralExpression.codegen(node, env, lObj)
    case 'CallExpression':
      return CallExpression.codegen(node, env, lObj)
    default:
      throw new Error('Not implemented. ' + JSON.stringify(node))
  }
}

function eval_toplevel(node: es.Node) {
  const context = new l.LLVMContext()
  const module = new l.Module('module', context)
  const builder = new l.IRBuilder(context)
  const env = new Environment(new Map<string, TypeRecord>(), new Map<any, l.Value>())
  evaluate({ node, env, lObj: { context, module, builder } })
  return module
}

export { eval_toplevel }
