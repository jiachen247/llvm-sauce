import { Context, createContext } from 'js-slang'
import { parse as slang_parse } from 'js-slang/dist/parser/parser'
import * as es from 'estree'
import * as fs from 'fs'

export class CompileError extends Error {
  constructor(message: string) {
    super(message)
  }
}

function main() {
  const opt = require('node-getopt')
    .create([['c', 'chapter=CHAPTER', 'set the Source chapter number (i.e., 1-4)', '1']])
    .bindHelp()
    .setHelp('Usage: llvm-sauce [OPTION] filename\n\n')
    .parseSystem()

  const chapter = parseInt(opt.options.chapter, 10)
  const filename = opt.argv[0]

  if (!filename || filename === '') {
    console.log('Usage: llvm-sauce [OPTION] filename\n\n')
    return
  }
  const code = fs.readFileSync(filename, 'utf8')

  compile(chapter, code)
}

function compile(chapter: number, code: string) {
  const context: Context = createContext(chapter)
  let estree: es.Program | undefined = slang_parse(code, context)

  if (!estree) {
    return Promise.reject(new CompileError('js-slang cannot parse the program'))
  }
  let es_str: string = JSON.stringify(estree)

  console.log(es_str)

  // compile should return LLVM IR
  return Promise.resolve(es_str)
}

main()
