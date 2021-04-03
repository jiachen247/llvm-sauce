function factorial(n) {
    function iter(product, counter) {
        return counter > n 
               ? product
               : iter(counter * product,
                      counter + 1);
   }
   return iter(1, 1);
}

display(factorial(5));
//120.000000