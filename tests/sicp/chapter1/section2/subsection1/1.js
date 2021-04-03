function factorial(n) {
    return n === 1 
           ? 1
           : n * factorial(n - 1);
}

factorial(5);
// expected: 120.000000