function inc(x) {
    return x + 1;
}
function dec(x) {
    return x - 1;
}
function plus(a, b) {
    return a === 0 ? b : plus(dec(a), inc(b));
}

display(plus(4, 5));
//9.000000