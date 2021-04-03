function gcd(a, b) {
    return b === 0 ? a : gcd(b, a % b);
}

gcd(20, 12);
// expected: 4.000000