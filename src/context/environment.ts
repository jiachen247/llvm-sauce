import { Value } from 'llvm-node'
import * as l from 'llvm-node'

enum Type {
  BOOLEAN,
  FUNCTION,
  NUMBER,
  STRING
}

interface Location {
  jumps: number
  offset: number
  base?: l.Value
  value?: l.Value // only if already declared within the function
}

interface Record {
  offset: number
  type?: Type
  signature?: [Type[], Type[]]
  value?: l.Value
}

class Environment {
  private names: Map<string, Record>
  private virtuals: Map<string, l.Value>
  private parent?: Environment
  private ptr?: Value // this stores the actual pointer to the frame
  private counter: number
  private isFunction: boolean
  private formals?: Array<string>
  constructor(isFunction: boolean, parent?: Environment, formals?: Array<string>) {
    this.names = new Map<string, Record>()
    this.virtuals = new Map<string, l.Value>()
    this.parent = parent
    this.counter = 0
    this.isFunction = isFunction
    this.formals = formals
  }

  static createNewEnvironment(
    isFunction: boolean = false,
    parent?: Environment,
    formals: Array<string> = []
  ): Environment {
    return new Environment(isFunction, parent, formals)
  }

  addRecord(name: string) {
    const record: Record = {
      offset: this.getNextOffset()
    }
    this.push(name, record)
  }

  push(name: string, tr: Record): void {
    this.names.set(name, tr)
  }

  contains(name: string): boolean {
    return this.names.has(name)
  }

  containsVirtual(name: string): boolean {
    return this.virtuals.has(name)
  }

  addVirtual(name: string, value: l.Value) {
    this.virtuals.set(name, value)
  }

  get(name: string): Record | undefined {
    return this.names.get(name)
  }

  getVirtual(name: string): l.Value | undefined {
    return this.virtuals.get(name)
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

  getNextOffset() {
    this.counter += 1
    return this.counter
  }

  isFunctionFrame() {
    return this.isFunction
  }

  getFormals(): Array<string> {
    return this.formals!
  }

  resetVirtuals() {
    this.virtuals = new Map<string, l.Value>()
  }
}

export { Environment, Location, Type, Record }
