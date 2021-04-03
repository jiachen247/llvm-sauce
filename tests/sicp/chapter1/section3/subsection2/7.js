function square(x) {
    return x * x;
}
display(((x, y, z) => x + y + square(z))(1, 2, 3));
//12.000000