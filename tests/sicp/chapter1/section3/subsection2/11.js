function h() {
    const y = 1;
    function i() {
        const x = y + 1;
        return x;
    }
    return i();
}
h();
// expected: 2.000000