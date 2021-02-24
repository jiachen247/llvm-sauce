const a = true;
const b = false;
const c = a && !a || !b;
const d = a && !(a || b);
display(a, b, c, d);

// 1 0 1 0