function expt(b,n) {
    return n === 0
           ? 1
           : b * expt(b, n - 1);
}

expt(3, 4);
// expected: 81.000000