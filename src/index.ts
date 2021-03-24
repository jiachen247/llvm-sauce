import { Context, createContext } from 'js-slang'
import { parse as slang_parse } from 'js-slang/dist/parser/parser'
import * as es from 'estree'
import * as fs from 'fs'
import * as llvm from 'llvm-node'
import { eval_toplevel } from './codegen/codegen'

export class CompileError extends Error {
  constructor(message: string) {
    super(message)
  }
}

function main() {
  const opt = require('node-getopt')
    .create([
      ['c', 'chapter=CHAPTER', 'set the Source chapter number (i.e., 1-4)', '1'],
      ['o', 'output=FILE', 'writes LLVM bytecode to a file, otherwise we print to stdout'],
      ['p', 'pretty', 'enable printing the parsed JSON'],
      ['h', 'help', 'print this help']
    ])
    .bindHelp()
    .parseSystem()

  const filename = opt.argv[0]
  if (!filename || filename === '') {
    console.info(opt.getHelp())
    return
  }
  const code = fs.readFileSync(filename, 'utf8')

  compile(opt.options, code)
}

function compile(options: any, code: string) {
  const chapter = parseInt(options.chapter, 10)
  const context: Context = createContext(chapter)
  let estree: es.Program | undefined = slang_parse( "{" + code + "}", context)

  if (!estree) {
    return Promise.reject(new CompileError('js-slang cannot parse the program'))
  }

  let es_str: string = JSON.stringify(estree, null, 4)
  if (options.pretty) console.log(es_str)

  const outputFile = options.output
  const module = eval_toplevel(estree)
  if (outputFile) {
    llvm.writeBitcodeToFile(module, outputFile)
  } else {
    console.log(module.print())
  }

  // compile should return LLVM IR
  return Promise.resolve(es_str)
}

main()
