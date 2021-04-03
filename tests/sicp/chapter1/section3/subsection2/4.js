function sum(term, a, next, b) {
    return a > b
           ? 0
           : term(a) + sum(term, next(a), next, b);
}
function cube(x) {
    return x * x * x;
}
function integral(f, a, b, dx) {
    return sum(f,
               a + dx / 2.0,
               x => x + dx,
               b)
           *
           dx;
}

display(integral(cube, 0, 1, 0.01));
//0.249988