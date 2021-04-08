
// https://dlqs.github.io/webscripten/demo/dist/index.html
// node dist/index.js --tco demo/demo3.js > demo/demo3.ll
function fib(n) {
    return n === 0
           ? 0
           : n === 1
             ? 1
             : fib(n - 1) + fib(n - 2);
}

fib(20);
// expected: 75025.000000