function gcd(a, b) {
    return b === 0 ? a : gcd(b, a % b);
}

display(gcd(20, 12));
//4.000000