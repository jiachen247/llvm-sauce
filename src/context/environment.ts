import { Value } from 'llvm-node'
enum Type {
  ARRAY,
  BOOLEAN,
  FUNCTION,
  NUMBER,
  STRING,
  UNKNOWN
}

interface TypeRecord {
  value: Value
  type?: Type
  // For functions, this records the function signature. [A, B] means sig of A => B.
  funSig?: [Type[], Type[]]
}

class Environment {
  private names: Map<string, TypeRecord>
  private globals: Map<any, Value>
  private child?: Environment
  constructor(theNames: Map<string, TypeRecord>, theGlobals: Map<any, Value>) {
    this.names = theNames
    this.globals = theGlobals
  }

  push(name: string, tr: TypeRecord): void {
    this.names.set(name, tr)
  }

  get(name: string): TypeRecord | undefined {
    return this.names.get(name)
  }

  getGlobal(name: any): Value | undefined {
    return this.globals.get(name)
  }

  add(name: string, value: TypeRecord): TypeRecord {
    this.names.set(name, value)
    return value
  }

  addGlobal(name: any, value: Value): Value {
    this.globals.set(name, value)
    return value
  }

  setChild(theChild: Environment): void {
    this.child = theChild
  }
}

export { Environment, Type, TypeRecord }
