# llvm-sauce

A yummy source to llvm IR compiler!

## Usage

You will want to build the package first.
```
yarn
yarn build
```
Following which, you can execute the program with `yarn start`. For example
```
yarn start -p tests/source0/test1.js
```

## Testing

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
- Display spaces out its arguments with a single space.