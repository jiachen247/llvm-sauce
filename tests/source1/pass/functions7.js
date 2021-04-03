function compose(f, g) {
    function a(x) {
        return f(g(x));
    }
    return a;
}

function add(x) {
    return x + 1;
}

function mul(x) {
    return x * 2;
}

const f = compose(add, mul);
f(5);
// expected: 11.000000