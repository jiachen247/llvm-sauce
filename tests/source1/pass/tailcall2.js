function fact(n, acc) {
    return n === 1
        ? acc 
        : fact(n - 1, n * acc);
}

display(fact(5, 1));
//120.000000