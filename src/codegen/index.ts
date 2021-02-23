import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, Type, TypeRecord } from '../context/environment'

interface LLVMObjs {
  context: l.LLVMContext
  module: l.Module
  builder: l.IRBuilder
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
    if (v) return v.value
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
  static codegen(node: es.BinaryExpression | es.LogicalExpression, env: Environment, lObj: LLVMObjs): l.Value {
    const lhs = evaluate({ node: node.left, env, lObj })
    const rhs = evaluate({ node: node.right, env, lObj })
    const left = lhs.type.isPointerTy() ? lObj.builder.createLoad(lhs) : lhs
    const right = rhs.type.isPointerTy() ? lObj.builder.createLoad(rhs) : rhs
    const operator = node.operator
    switch (operator) {
      case '+':
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
      case "===":
        return lObj.builder.createFCmpOEQ(left, right)
      case "<=":
        return lObj.builder.createFCmpOLE(left, right)
      case ">=":
        return lObj.builder.createFCmpOGE(left, right)
      case "&&":
        return lObj.builder.createAnd(left, right)
      case "||":
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
      case "string":
        const len = value.length
        const arrayType = l.ArrayType.get(l.Type.getInt32Ty(lObj.context), len)
        const elements = Array.from(value).map(x => l.ConstantInt.get(lObj.context, x.charCodeAt(0)))
        return l.ConstantArray.get(arrayType, elements)
      case "number":
        return l.ConstantFP.get(lObj.context, value)
      case "boolean":
        return value ? l.ConstantInt.getTrue(lObj.context) : l.ConstantInt.getFalse(lObj.context)
      default:
        throw new Error("Unimplemented literal type " + typeof value)
    }
  }
}
class VariableDeclarationExpression {
  static codegen(node: es.VariableDeclaration, env: Environment, lObj: LLVMObjs): l.Value {
    const kind = node.kind
    if (kind !== 'const') throw new Error('We can only do const right now')
    const context = lObj.context
    const module = lObj.module
    const builder = lObj.builder
    const decl = node.declarations[0]
    const id = decl.id
    const init = decl.init
    let name: string | undefined
    let value: any
    let type: Type
    let initializer
    if (id.type === 'Identifier') name = id.name
    if (init) {
      value = evaluate({ node: init, env, lObj })
    }
    if (value === undefined || !name) {
      console.log(value)
      throw new Error('Something wrong with the literal\n' + JSON.stringify(node))
    }
    let allocInst: l.AllocaInst
    let storeInst: l.Value
    allocInst = builder.createAlloca(value.type, undefined, name)
    storeInst = builder.createStore(value, allocInst, false)
    env.push(name, { value: allocInst })
    return allocInst
  }
}

function evaluate({ node, env, lObj }: { node: es.Node; env: Environment; lObj: LLVMObjs }): l.Value {
  switch(node.type) {
    case "Program":
      return ProgramExpression.codegen(node, env, lObj)
    case "VariableDeclaration":
      return VariableDeclarationExpression.codegen(node, env, lObj)
    case "Identifier":
      return IndentifierExpression.codegen(node, env, lObj)
    case "ExpressionStatement":
      return Expression.codegen(node, env, lObj)
    case "UnaryExpression":
      return UnaryExpression.codegen(node, env, lObj)
    case "LogicalExpression":
      return BinaryExpression.codegen(node, env, lObj)
    case "BinaryExpression":
      return BinaryExpression.codegen(node, env, lObj)
    case "Literal":
      return LiteralExpression.codegen(node, env, lObj)
    default:
      throw new Error("Not implemented. " + JSON.stringify(node))
  }
}

function eval_toplevel(node: es.Node) {
  const context = new l.LLVMContext()
  const module = new l.Module('module', context)
  const builder = new l.IRBuilder(context)
  const env = new Environment(new Map<string, TypeRecord>(), undefined)
  evaluate({ node, env, lObj: { context, module, builder } })
  return module
}

export { eval_toplevel }
