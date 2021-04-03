function expt(b,n) {
    return n === 0
           ? 1
           : b * expt(b, n - 1);
}

display(expt(3, 4));
//81.000000