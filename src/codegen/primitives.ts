/* Contains primitive (predeclared) functions and values. */

import * as l from 'llvm-node'
import { Environment } from '../context/environment'
import { isBool, isNumber, isString } from '../util/util'
import { LLVMObjs } from '../types/types'

// Prints number or strings. Vararg.
function display(args: l.Value[], env: Environment, lObj: LLVMObjs) {
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
  args = args.map(x => (isBool(x) ? boolConv(x) : x))
  const fmtptr = lObj.builder.createGlobalStringPtr(fmt, 'format')
  const funtype = l.FunctionType.get(
    l.Type.getInt32Ty(lObj.context),
    [l.Type.getInt8PtrTy(lObj.context)],
    true)
  const fun = lObj.module.getOrInsertFunction('printf', funtype)
  return lObj.builder.createCall(fun.functionType, fun.callee, [fmtptr].concat(args))
}

function malloc(args: l.Value[], env: Environment, lObj: LLVMObjs) {
  const funtype = l.FunctionType.get(
    l.Type.getInt32PtrTy(lObj.context),
    [l.Type.getInt32Ty(lObj.context)],
    false)
  const fun = lObj.module.getOrInsertFunction('malloc', funtype)
  return lObj.builder.createCall(fun.functionType, fun.callee, args)
}

export { display, malloc }