function factorial(n, acc) {
    return n === 1
        ? acc
        : factorial(n - 1, n  * acc);
}
factorial(10, 1);
// expected: 3628800.000000