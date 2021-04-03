function fib(n) {
    return n === 0
           ? 0
           : n === 1
             ? 1
             : fib(n - 1) + fib(n - 2);
}

display(fib(6));
//8.000000