function f(g) {
   return g(2);
}
f(z => z * (z + 1));
// expected: 6.000000