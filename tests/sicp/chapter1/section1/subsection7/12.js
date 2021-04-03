function conditional(predicate, then_clause, else_clause) {		    
    return predicate ? then_clause : else_clause;
}
display(conditional(1 === 1, 0, 5));
//0.000000