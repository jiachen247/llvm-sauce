function cube(x) {
    return x * x * x;
}
function sum(term, a, next, b) {
    return a > b
           ? 0
           : term(a) + sum(term, next(a), next, b);
}
function inc(n) {
    return n + 1;
}
function sum_cubes(a, b) {
    return sum(cube, a, inc, b);
}

sum_cubes(1, 10);
// expected: 3025.000000