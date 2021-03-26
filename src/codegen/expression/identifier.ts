import * as es from 'estree'
import * as l from 'llvm-node'
import { Environment, TypeRecord } from '../../context/environment'
import { LLVMObjs } from '../../types/types'
import { lookup_env } from '../helper'

function evalIdentifierExpression(node: es.Identifier, env: Environment, lObj: LLVMObjs): l.Value {
  const { jumps, offset } = lookup_env(node.name, env)
  let frame = env.getFrame()!

  const literalStructType = lObj.module.getTypeByName('literal')!
  const literalStructPtr = l.PointerType.get(literalStructType, 0)!
  const literalStructPtrPtr = l.PointerType.get(literalStructPtr, 0)!

  for (let i = 0; i < jumps; i++) {
    const tmp = lObj.builder.createBitCast(frame, l.PointerType.get(frame.type, 0)!)
    frame = lObj.builder.createLoad(tmp)
  }

  const frameCasted = lObj.builder.createBitCast(frame, literalStructPtrPtr)
  const addr = lObj.builder.createInBoundsGEP(literalStructPtr, frameCasted, [
    l.ConstantInt.get(lObj.context, offset)
  ])

  return lObj.builder.createLoad(addr)
}

export { evalIdentifierExpression }
