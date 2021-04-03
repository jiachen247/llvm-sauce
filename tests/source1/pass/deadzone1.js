function f() {
    display(y);
    const y = 1;
}
f();
// expected: undefined
// expected: undefined