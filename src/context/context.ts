enum Type {
  NUMBER,
  STRING,
  FUNCTION
}

interface Value {
  type: Type
  value: any
}

class Environment {
  names: { [name: string] : Value }
  child: Environment | undefined
  constructor(
    theNames: { [name: string] : Value },
    theChild: Environment | undefined
  ) {
    this.names = theNames
    this.child = theChild
  }

  setChild(theChild: Environment) {
    this.child = theChild
  }
}

export { Environment, Type, Value }
