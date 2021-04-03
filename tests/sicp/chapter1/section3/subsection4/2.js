function average_damp(f) {
    return x => average(x, f(x));
}
function average(x,y) {
    return (x + y) / 2;
}
function square(x) {
    return x * x;
}
display(average_damp(square)(10));
//55.000000