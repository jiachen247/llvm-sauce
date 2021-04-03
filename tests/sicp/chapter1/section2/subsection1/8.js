function A(x,y) {
    return y === 0
           ? 0
           : x === 0
             ? 2 * y
             : y === 1
               ? 2
               : A(x - 1, A(x, y - 1));
}
display(A(2, 4));
//65536.000000