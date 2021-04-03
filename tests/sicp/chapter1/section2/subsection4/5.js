function times(a,b) {
    return b === 0
           ? 0
           : a + times(a, b - 1);
}

times(3, 4);
// expected: 12.000000