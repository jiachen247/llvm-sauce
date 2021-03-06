function factorial(asd) {
    if (asd === 1) {
        return 1;
    } else {
        return asd * factorial(asd-1);
    }
}

display(factorial(5));

// 120.000000