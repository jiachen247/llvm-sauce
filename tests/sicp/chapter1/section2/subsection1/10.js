function A(x,y) {
    return y === 0
           ? 0
           : x === 0
             ? 2 * y
             : y === 1
               ? 2
               : A(x - 1, A(x, y - 1));
}
function f(n) {
    return A(0, n);
}
function g(n) {
    return A(1, n);
}
function h(n) {
    return A(2, n);
}
function k(n) {
   return 5 * n * n;
}

display(k(4));
//80.000000