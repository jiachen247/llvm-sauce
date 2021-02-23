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
    node.body.map(x => evaluate(x, env, lObj))
    lObj.builder.createRetVoid()
    l.verifyFunction(mainFun)
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
    return evaluate(expr, env, lObj)
  }
}
class BinaryExpression {
  static codegen(node: es.BinaryExpression, env: Environment, lObj: LLVMObjs): l.Value {
    const lhs = evaluate(node.left, env, lObj)
    const rhs = evaluate(node.right, env, lObj)
    const left = lObj.builder.createLoad(lhs)
    const right = lObj.builder.createLoad(rhs)
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
      default:
        throw new Error('Unknown operator ' + operator)
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
    let raw: string | undefined
    let type: Type
    if (id.type === 'Identifier') name = id.name
    if (init && init.type === 'Literal') {
      value = init.value
      raw = init.raw
    }
    if (!value || !name)
      throw new Error('Something wrong with the literal\n' + JSON.stringify(node, null, 2))
    let initializer
    let allocInst: l.AllocaInst
    let storeInst: l.Value
    switch (typeof value) {
      case 'string':
        const len = value.length
        const arrayType = l.ArrayType.get(l.Type.getInt32Ty(context), len)
        const elements = Array.from(value).map(x => l.ConstantInt.get(context, x.charCodeAt(0)))
        initializer = l.ConstantArray.get(arrayType, elements)
        allocInst = builder.createAlloca(arrayType, undefined, name)
        storeInst = builder.createStore(initializer, allocInst, false)
        type = Type.STRING
        break
      case 'number':
        const doubleType = l.Type.getDoubleTy(context)
        initializer = l.ConstantFP.get(context, value)
        allocInst = builder.createAlloca(doubleType, undefined, name)
        storeInst = builder.createStore(initializer, allocInst, false)
        type = Type.NUMBER
        break
      case 'boolean':
        const intType = l.Type.getInt32Ty(context)
        initializer = value ? l.ConstantInt.getTrue(context) : l.ConstantInt.getFalse(context)
        allocInst = builder.createAlloca(intType, undefined, name)
        storeInst = builder.createStore(initializer, allocInst, false)
        type = Type.BOOLEAN
        break
      default:
        throw new Error('Unrecognized datatype')
    }
    env.push(name, { type, value: allocInst })
    return allocInst
  }
}

const jumpTable = {
  Program: ProgramExpression.codegen,
  VariableDeclaration: VariableDeclarationExpression.codegen,
  Identifier: IndentifierExpression.codegen,
  ExpressionStatement: Expression.codegen,
  BinaryExpression: BinaryExpression.codegen
}

function evaluate(node: es.Node, env: Environment, lObj: LLVMObjs): l.Value {
  return jumpTable[node.type](node, env, lObj)
}

function eval_toplevel(node: es.Node) {
  const context = new l.LLVMContext()
  const module = new l.Module('module', context)
  const builder = new l.IRBuilder(context)
  const env = new Environment(new Map<string, TypeRecord>(), undefined)
  evaluate(node, env, { context, module, builder })
  return module
}

export { eval_toplevel }
