function fact(n, acc) {
    return n === 1
        ? acc 
        : fact(n - 1, n * acc);
}

fact(5, 1);
// expected: 120.000000