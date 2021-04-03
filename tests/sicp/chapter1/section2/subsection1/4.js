function inc(x) {
    return x + 1;
}
function dec(x) {
    return x - 1;
}
function plus(a, b) {
    return a === 0 ? b : inc(plus(dec(a), b)); 
}

display(plus(4, 5));
//9.000000