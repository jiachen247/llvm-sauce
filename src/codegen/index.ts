import * as es from 'estree'
import * as l from 'llvm-node'
import { stringify } from 'querystring'
import { Environment, Type, Value } from '../context/context'

class ProgramExpression {
  static codegen(node: es.Program, env: Environment, context: l.LLVMContext, module: l.Module): any {
    const body: Array<es.Directive | es.Statement | es.ModuleDeclaration> = node.body
    body.forEach(x => evaluate(x, env, context, module))
  }
}
class VariableDeclarationExpression {
  static codegen(node: es.VariableDeclaration, env: Environment, context: l.LLVMContext, module: l.Module) {
    const kind = node.kind
    if (kind !== "const") {
      Error("We can only do const right now")
    }
    const decl = node.declarations[0]
    const id = decl.id
    const init = decl.init
    let name = undefined;
    let value = undefined;
    let raw = undefined;
    if (id.type === "Identifier") {
      name = id.name;
    }
    if (init && init.type === "Literal") {
      value = init.value;
      raw = init.raw
    }
    if (name && value) {
      switch(typeof value) {
        case "string":
          break;
        case "number":
          const intType = l.Type.getInt32Ty(context);
          const initializer = l.ConstantInt.get(context, value);
          const globalVariable = new l.GlobalVariable(module, intType, true, l.LinkageTypes.InternalLinkage, initializer)
          break;
        case "boolean":
          break;
      }
    } else {
      Error("Something wrong with the literal\n" + JSON.stringify(node, null, 2));
    }
  }
}

const jumpTable: { [id: string]: any } = {
  "Program": ProgramExpression,
  "VariableDeclaration": VariableDeclarationExpression
}

function evaluate(node: es.Node, env: Environment, context: l.LLVMContext, module: l.Module) {
  jumpTable[node.type].codegen(node, env, context, module)
}

function eval_toplevel(node: es.Node) {
  const context = new l.LLVMContext()
  const module = new l.Module('module', context)
  const env = new Environment({}, undefined)
  evaluate(node, env, context, module)
  return module
}

export { eval_toplevel }
