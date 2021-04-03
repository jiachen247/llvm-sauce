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
display(f(5));
//11.000000