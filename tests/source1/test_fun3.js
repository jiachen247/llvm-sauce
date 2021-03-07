function fib(i) {
    function helper(p1, p2, i) {
        return i <= 1
            ? p2
            : helper(p2, p1 + p2, i-1);
    }

    return i === 0 ? 0 : i === 1 ? 1 : helper(0, 1, i);
}

display(fib(10));

// 55.000000