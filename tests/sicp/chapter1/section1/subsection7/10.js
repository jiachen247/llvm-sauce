function conditional(predicate, then_clause, else_clause) {		    
    return predicate ? then_clause : else_clause;
}
display(conditional(2 === 3, 0, 5));
//5.000000