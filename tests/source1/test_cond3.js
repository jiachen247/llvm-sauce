// nested conditionals test
const a = 3.14;
const b =
    a < 2
    ? 1
    : a < 3
    ? 2
    : a === 3
    ? 3
    : a > 3
    ? 4
    : 5;

display(b);

// 4.000000