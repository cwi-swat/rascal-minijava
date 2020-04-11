module lang::minijavarepl::AbstractSyntax


data expr = lit(value v)
          | length(expr e)
          | tt()
          | ff()
          | ref(str id)
          | new_array(expr e)
          | new_object(str id)
          | array_index(expr p, expr q)
          | method_call(expr p, str id, [expr] actuals)
          | not(expr e)
          | mult(expr p, expr q)
          | plus(expr p, expr q)
          | minus(expr p, expr q)
          | less_than(expr p, expr q)
          | and(expr p, expr q)
          ;
          
data stmt = if_then_else(expr e, stmt s1, stmt s2)
		  | while_loop(expr e, stmt s)
		  | print(expr e)
		  | assign(str i, expr e)
		  | array_assign(str i, expr p, expr q)
		  | done()
		  | seq(stmt s1, stmt s2)
		  ;
		
data decl = vardecl(str ty, str id);
		
data phrase = phrase_decl(decl d)
   	        | phrase_stmt(stmt s)
   	        | phrase_seq(phrase p, phrase q)
   	        | phrase_skip()
   	        ;
		
data auxiliary = new_references(int n, value v)
			   | new_reference(value v)
			   | close(stmt s)
			   | scope(decl d, node t)
			   | accumulate(decl p, decl q)
			   ;
			   
data auxiliary_values
			= closure(map[str,value] env, stmt s)
			;
