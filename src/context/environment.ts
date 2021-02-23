enum Type {
  BOOLEAN,
  FUNCTION,
  NUMBER,
  STRING
}

interface TypeRecord {
  type: Type
  // For functions, this records the function signature. [A, B] means sig of A => B.
  funSig?: [Type[], Type[]]
}

class Environment {
  names: Map<string, TypeRecord>
  child: Environment | undefined
  constructor(theNames: Map<string, TypeRecord>, theChild: Environment | undefined) {
    this.names = theNames
    this.child = theChild
  }

  push(name: string, tr: TypeRecord): void {
    this.names.set(name, tr)
  }

  setChild(theChild: Environment): void {
    this.child = theChild
  }
}

export { Environment, Type, TypeRecord }
