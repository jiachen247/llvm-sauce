function fact(n, acc) {
    if (n === 1) {
        return acc;
    } else {
        return fact(n - 1, n * acc);
    }
}

fact(5, 1);
// expected: 120.000000