function square(x) {
    return x * x;
}
function f(x,y) {
    return ( (a,b) => x * square(a) + 
                      y * b + 
                      a * b
           )(1 + x * y, 1 - y);
}

display(f(3, 4));
//456.000000