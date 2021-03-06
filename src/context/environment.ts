import { Value, BasicBlock } from 'llvm-node'

enum Type {
  ARRAY,
  BOOLEAN,
  FUNCTION,
  NUMBER,
  STRING,
  UNKNOWN
}

enum Location {
  BLOCK,
  FUNCTION
}

interface Record {
  value: Value
  type?: Type
  // For functions, this records the function signature. [A, B] means sig of A => B.
  funSig?: [Type[], Type[]]
}

class Environment {
  private names: Map<string, Record>
  private globals?: Map<any, Value>
  public loc: Location
  private parent?: Environment
  constructor(theNames: Map<string, Record>, theLoc: Location, theGlobals?: Map<any, Value>) {
    this.names = theNames
    this.loc = theLoc
    this.globals = theGlobals ? theGlobals : undefined
  }

  push(name: string, tr: Record): void {
    this.names.set(name, tr)
  }

  get(name: string): Record | undefined {
    let v = this.names.get(name)
    if (!v) {
      if (this.parent) {
        return this.parent.get(name)
      }
      return undefined
    }
    return v
  }

  getGlobal(name: any): Value | undefined {
    return this.globals?.get(name)
  }

  add(name: string, value: Record): Record {
    this.names.set(name, value)
    return value
  }

  addGlobal(name: any, value: Value): Value {
    this.globals?.set(name, value)
    return value
  }

  // Sets the parent of this to be to the argument.
  // An environment can be the parent of multiple others.
  setParent(theParent: Environment): void {
    this.parent = theParent
  }
}

export { Environment, Location, Type, Record as TypeRecord }
