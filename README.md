# :rocket: LLVM Sauce 

LLVM Sauce is a Source (https://source-academy.github.io/source/) compiler built with the LLVM framework. More specifially, it implements a source frontend that takes in source and outputs LLVM Intemediate Representation (IR). This IR can then be optimized, interpreted or compiled futhur with the LLVM tools.

A technical specification for the compiler can be found at ___. todo

![](https://i.imgur.com/NExfvra.png)

### Features
- A fully featured [Source 1](https://source-academy.github.io/source/source_1/) langauge compiler
- A compiler that respects the Proper Tail Call (PTC) semantics of [ECMAScript 2015 Language Specification](https://262.ecma-international.org/6.0/#sec-preparefortailcall)


## Getting Started

### System Requirements
- A 64 bit Linux System

Notes:
- Currently build and tested on `Ubuntu 20.04.1 LTS x86_64 GNU/Linux` with `LLVM 10.0.0`.
- Windows and MacOS are not currently supported due to CMake dependencies on `llvm-node`.

### Installing System Dependencies
Feel free to skip this section if you already have the dependencies installed.

System Dependencies include
- LLVM Framework v10.0.0+
- Nodejs 10+
- Yarn
- G++
- CMake

Refer to this [gist](https://gist.github.com/jiachen247/d6e85aedd34fa570284dd981ae3f00bb) for a seperate guide on installing all the necessary system dependencies including the LLVM framework on an Ubuntu VM.

### Setup
1. Clone repositry to your local file system with `git clone https://github.com/jiachen247/llvm-sauce.git`
2. Go into the project directory and install dependenceies with `yarn install`
3. To build the project run `yarn build`

### Compiling a Source file
- todo

## Development Guide
- todo

### Testing
- todo

### Application Structure
- todo

<!-- ## Usage

You will want to build the package first.
```
yarn
yarn build
```
Following which, you can execute the program with `yarn start`. For example
```
yarn start -p tests/source0/test1.js
``` -->

<!-- ## Testing

We have a very rudimentary test script since there is not much else that we
need. To write a test, create a file named `test_<description>.js` inside
`/tests/source?/`. Tests have this format:
```js
<source_program>
// expected output
```
Note that only the *last line* is taken as expected output. For the program
to even compile it must also be a proper Source comment. Spaces immediately
after `//` does not matter. To test multiple things at the same time, it may
be useful to know that `display()` is varag and you can do `display(a,b,c)`
for example. It is most helpful to look at existing tests and copy/paste them.

There might be some quirks that one must keep in mind to write tests. These
occur because there is no effort put into sanitizing things because it is not
needed right now.

- All numbers are `double`. Printed numbers go to 6 decimal places, even for
example `display(3)`
- Booleans are `int1`. Therefore `display(true)` gives `1`, and
`display(false)` gives `0`.
- Display spaces out its arguments with a single space. -->