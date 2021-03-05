import { Value, BasicBlock } from 'llvm-node'

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
  private globals?: Map<any, Value>
  private child?: Environment
  private parent?: Environment
  constructor(theNames: Map<string, TypeRecord>, theGlobals?: Map<any, Value>) {
    this.names = theNames
    this.globals = theGlobals ? theGlobals : undefined
  }

  push(name: string, tr: TypeRecord): void {
    this.names.set(name, tr)
  }

  get(name: string): TypeRecord | undefined {
    let v = this.names.get(name)
    if (!v) {
      if (this.parent) {
        return this.parent.get(name)
      }
      return undefined
    }
    return v;
  }

  getGlobal(name: any): Value | undefined {
    return this.globals?.get(name)
  }

  add(name: string, value: TypeRecord): TypeRecord {
    this.names.set(name, value)
    return value
  }

  addGlobal(name: any, value: Value): Value {
    this.globals?.set(name, value)
    return value
  }

  // Sets the child of this to point to the argument.
  // Also sets the parent of the argument to this.
  setChild(theChild: Environment): void {
    this.child = theChild
    theChild.setParent(this)
  }

  // Sets the parent of this to point to the argument.
  // Does not set the child of the argument.
  setParent(theParent: Environment): void {
    this.parent = theParent
  }
}

export { Environment, Type, TypeRecord }
