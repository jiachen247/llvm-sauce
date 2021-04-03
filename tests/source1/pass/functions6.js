function f() {
    function g() {
        return 100;
    }

    return g();
}

f();
// expected: 100.000000