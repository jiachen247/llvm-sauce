import { Value, BasicBlock, StructType } from 'llvm-node'

enum Location {
  BLOCK,
  FUNCTION
}

enum Type {
  ARRAY,
  BOOLEAN,
  FUNCTION,
  NUMBER,
  STRING,
  UNKNOWN
}

interface Record {
  value: Value
  type: Type
  // For functions, this records the function signature. [A, B] means sig of A => B.
  funSig?: [Type[], Type[]]
}

class Environment {
  public names: Map<string, Record>
  public loc: Location
  public context?: Value // this is the malloc'ed frame
  public globals?: Map<any, Value>
  private parent?: Environment
  constructor(theNames: Map<string, Record>, theLoc: Location, theContext?: Value) {
    this.names = theNames
    this.loc = theLoc
    if (theContext)
      this.context = theContext
  }

  push(name: string, tr: Record): void {
    this.names.set(name, tr)
  }

  add(name: string, value: Record): Record {
    this.names.set(name, value)
    return value
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

  // Return all names defined in this environment in the sequence of parent's,
  // then this'
  findAllNames(): Map<string, Record> {
    const res = new Map<string, Record>()
    if(this.parent) {
      const temp = this.parent.findAllNames()
      temp.forEach((r, k) => {
        if (r.type !== Type.FUNCTION)
          res.set(k, r)
      });
    }
    this.names.forEach((r, k) => {
      if (r.type !== Type.FUNCTION)
        res.set(k, r)
    });
    // TODO: Allow functions. Right now we cannot do this because the main
    // function does not have a context.
    return res
  }

  // Return all names defined in parent and parent's parent and so on. The
  // furthest ancestor's names will be closer to the beginning of the map.
  findAllParentsNames(): Map<string, Record> {
    if (this.parent)
      return this.parent.findAllNames()
    else
      return new Map<string, Record>()
  }

  getGlobal(name: any): Value | undefined {
    return this.globals?.get(name)
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

  // Creates and returns a child env that inherits the context of its parent.
  createChild(theLoc: Location) {
    const theNames = new Map<string, Record>()
    const c = new Environment(theNames, theLoc, this.context)
    c.setParent(this)
    return c
  }
}

export { Environment, Location, Type, Record }
