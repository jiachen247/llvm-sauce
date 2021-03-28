const f = x => x + 1;
const g = x => x * 2;

const compose = f => g => x => f(g(x));

const fun = compose(f)(g);
const result = fun(200);
display(result);
//401.000000