import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { evaluateExpression } from '../codegen'
import { display, lookup_env } from '../helper'
import { formatFunctionName } from '../statement/function'

function evalCallExpression(node: es.CallExpression, env: Environment, lObj: LLVMObjs): l.Value {
  const callee = (node.callee as es.Identifier).name

  const args = node.arguments.map(x => evaluateExpression(x, env, lObj))

  const builtins: { [id: string]: () => l.CallInst } = {
    display: () => display(args, env, lObj)
  }

  const built = builtins[callee]
  let fun
  
  if (!built) {
    const fun = lObj.module.getFunction(formatFunctionName(callee))


    if (!fun ) { 
      throw new Error('Undefined function ' + callee)
    } 

    const loc = lookup_env(callee, env)
    let frame = env.getPointer()! // frame enclosing function eyeballs
 

    const literalStructType = lObj.module.getTypeByName('literal')!
    const literalStructPtr = l.PointerType.get(literalStructType, 0)!
    const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)!
  
    let tmp
    for (let i = 0; i < loc.jumps; i++) {
      tmp = lObj.builder.createBitCast(frame, literalStructPtrPtr)
      frame = lObj.builder.createLoad(tmp)
    }
    tmp = lObj.builder.createBitCast(frame, literalStructPtr)
    args.unshift(tmp) // place this frame as the first arg
    
    return lObj.builder.createCall(fun.type.elementType as l.FunctionType, fun, args)
  } else {
    return built() // a bit of that lazy evaluation
  }

  return l.ConstantFP.get(lObj.context, 1)
}

export { evalCallExpression }
