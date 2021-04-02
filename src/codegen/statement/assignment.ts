import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { lookupEnv } from '../helper'
import { evaluateExpression } from '../codegen'

function evalVariableDeclarationExpression(
  node: es.VariableDeclaration,
  env: Environment,
  lObj: LLVMObjs
) {
  const decl = node.declarations[0]
  const id = decl.id
  const init = decl.init
  let name = (id as es.Identifier).name
  let value: l.Value

  // should always hit here in source one (parser will enfore this for us)
  if (init) {
    value = evaluateExpression(init!, env, lObj)
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
  }
}

export { evalVariableDeclarationExpression }
