import { Value } from 'llvm-node'
import * as l from 'llvm-node'

enum Type {
  ARRAY,
  BOOLEAN,
  FUNCTION,
  NUMBER,
  STRING,
  UNKNOWN
}

interface TypeRecord {
  offset: number
  // depreceated
  // value?: Value
  type?: Type
  // For functions, this records the function signature. [A, B] means sig of A => B.
  funSig?: [Type[], Type[]]
}

class Environment {
  private names: Map<string, TypeRecord>
  private globals: Map<any, Value>
  private parent?: Environment
  private frame?: Value
  constructor(theNames: Map<string, TypeRecord>, theGlobals: Map<any, Value>) {
    this.names = theNames
    this.globals = theGlobals
    this.parent = undefined
  }

  static createNewEnvironment() {
    return new Environment(new Map<string, TypeRecord>(), new Map<any, l.Value>())
  }

  addRecord(name: string, offset: number) {
    const record: TypeRecord = {
      offset: offset
    }
    this.push(name, record)
  }

  push(name: string, tr: TypeRecord): void {
    this.names.set(name, tr)
  }

  contains(name: string): boolean {
    return this.names.has(name)
  }

  get(name: string): TypeRecord | undefined {
    return this.names.get(name)
  }

  getOffset(name: string): number | undefined {
    return this.names.get(name)!.offset
  }

  getGlobal(name: any): Value | undefined {
    return this.globals.get(name)
  }

  addType(name: string, value: TypeRecord): TypeRecord {
    this.names.set(name, value)
    return value
  }

  addGlobal(name: any, value: Value): Value {
    this.globals.set(name, value)
    return value
  }

  setParent(theParent: Environment): void {
    this.parent = theParent
  }

  getParent(): Environment | undefined {
    return this.parent
  }

  getFrame() {
    return this.frame
  }

  setFrame(value: l.Value) {
    this.frame = value
  }
}

export { Environment, Type, TypeRecord }
