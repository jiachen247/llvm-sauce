// `let x = 1;` is a assignment statement while
// `x = 1;` is an assignment expression

import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { evaluateExpression } from '../codegen'
import { lookupEnv } from '../helper'

function evalAssignmentExpression(
  node: es.AssignmentExpression,
  env: Environment,
  lObj: LLVMObjs
): l.Value {
  const id = node.left as es.Identifier // has to be an id
  let name = (id as es.Identifier).name
  let value: l.Value

  value = evaluateExpression(node.right, env, lObj)
  let frame = env.getPointer()!

  // write pointer to value to env frame
  const literalType = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalType, 0)!
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)!

  const { jumps, offset } = lookupEnv(name, env)

  for (let i = 0; i < jumps; i++) {
    const tmp = lObj.builder.createBitCast(frame, l.PointerType.get(frame.type, 0)!)
    frame = lObj.builder.createLoad(tmp)
  }

  const frame_casted = lObj.builder.createBitCast(frame, literalStructPtrPtr)
  const ptr = lObj.builder.createInBoundsGEP(literalStructPtr, frame_casted, [
    l.ConstantInt.get(lObj.context, offset)
  ])

  lObj.builder.createStore(value, ptr, false)
  return value
}

export { evalAssignmentExpression }
