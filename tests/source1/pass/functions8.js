function factorial(n, acc) {
    return n === 1
        ? acc
        : factorial(n - 1, n  * acc);
}
display(factorial(10, 1));
//3628800.000000