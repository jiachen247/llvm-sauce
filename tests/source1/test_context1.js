
function fast_power(b, e) {
    function fast() {
        function power() {
            return e === 0 
                ? 1 
                : e % 2 === 0
                    ? fast_power(b * b, e / 2)
                    : b * fast_power(b, e - 1);
        }
        return power();
    }
    return fast();
}

display(fast_power(2, 10));

// 1024.000000