function times(a,b) {
    return b === 0
           ? 0
           : a + times(a, b - 1);
}

display(times(3, 4));
//12.000000