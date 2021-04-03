function f(g) {
   return g(2);
}
function square(x) {
    return x * x;
}
f(square);
// expected: 4.000000