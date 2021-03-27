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

interface Location {
  jumps: number
  offset: number
}

interface Record {
  offset: number
  type?: Type
  signature?: [Type[], Type[]]
}

class Environment {
  private names: Map<string, Record>
  private parent?: Environment
  private ptr?: Value // this stores the actual pointer to the frame
  constructor(theNames: Map<string, Record>, parent?: Environment) {
    this.names = theNames
    this.parent = parent
  }

  static createNewEnvironment(parent?: Environment) {
    return new Environment(new Map<string, Record>(), parent)
  }

  addRecord(name: string, offset: number) {
    const record: Record = {
      offset: offset
    }
    this.push(name, record)
  }

  push(name: string, tr: Record): void {
    this.names.set(name, tr)
  }

  contains(name: string): boolean {
    return this.names.has(name)
  }

  get(name: string): Record | undefined {
    return this.names.get(name)
  }

  getOffset(name: string): number | undefined {
    return this.names.get(name)!.offset
  }

  addType(name: string, value: Record): Record {
    this.names.set(name, value)
    return value
  }

  setParent(theParent: Environment): void {
    this.parent = theParent
  }

  getParent(): Environment | undefined {
    return this.parent
  }

  getPointer() {
    return this.ptr
  }

  setPointer(value: l.Value) {
    this.ptr = value
  }
}

export { Environment, Location, Type, Record }
