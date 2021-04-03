function cube(x) {
    return x * x * x;
}
function sum_cubes(a, b) {
    return a > b
           ? 0
           : cube(a) + sum_cubes(a + 1, b);
}

display(sum_cubes(3, 7));
//775.000000