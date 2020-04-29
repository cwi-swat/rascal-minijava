module lang::minijavarepl::Interpreter

import lang::minijavarepl::AuxiliarySyntax;
import lang::minijava::Syntax;
import lang::minijavarepl::Syntax;
extend lang::minijava::Interpreter;

import lang::std::Layout;

import util::Maybe;
import IO;

Context eval((Program) `<Phrase P>`) = eval(P);

Context eval(Phrase p) = eval(p, empty_context());	
Context eval((Phrase) `<Expression E> ;`, Context c)        = eval((Phrase) `System.out.println(<Expression E>);`, c);
Context eval((Phrase) `<Statement S>`, Context c)           = exec(S, c);
Context eval((Phrase) `<ClassDecl CD>`, Context c)          = collect_bindings(declare_class(CD, c));
Context eval((Phrase) `<VarDecl VD>`, Context c)            = collect_bindings(declare_variables(VD, c));
Context eval((Phrase) `<MethodDecl MD>`, Context c)         = collect_bindings(declare_global_method(MD, c));
Context eval((Phrase) `<Phrase P1> <Phrase P2>`, Context c) = eval(P2, eval(P1,c));

Context collect_bindings(Context c) {
  if (envlit(new) := get_result(c)) {
    c.env = c.env + new;
  }
  return c;
}

Context exec(Statement s, Context c) = exec(c,s);
Context declare_variables(VarDecl VD, Context c) = declare_variables(c, [VD]); 

Context declare_class(ClassDecl CD, Context c) {
  c = bind_class_occurrences_(c, class_occurrences(CD));
  if (!c.failed && envlit(env) := get_result(c)) {
    return redeclare_class(env_override(c, env), CD);
  }
  else return set_fail(c);
}

Context redeclare_class(Context c, (ClassDecl) 
  `class <Identifier ID1> extends <Identifier ID2> { <VarDecl* VDs> <MethodDecl* MDs> }`) 
  = redeclare_class(c, ID1, VDs, MDs, just("<ID2>"));
Context redeclare_class(Context c, (ClassDecl) 
  `class <Identifier ID1> { <VarDecl* VDs> <MethodDecl* MDs> }`) 
  = redeclare_class(c, ID1, VDs, MDs, nothing());
Context redeclare_class(Context c, ID, VDs, MDs, Maybe[str] mID2) {
  c = declare_class_val(c, ID, VDs, MDs, mID2);
  if (!c.failed && classlit(class_val) := get_result(c)) {
    try {
	    if(ref(r) := c.env["<ID>"]) {
	  	  if (classlit(old_class) := c.sto[r]) {
	  	    return set_result(sto_override(c, ( r : classlit(class_override(class_val,old_class)) )), envlit(( "<ID>" : ref(r))));
	  	  }
	  	  else {
	  	    return set_result(sto_override(c, ( r : classlit(class_val) )), envlit(( "<ID>" : ref(r))));
	  	  }  
	    }
	    else return set_fail(c);
	}    
	catch exc: {print(exc); return set_fail(c);}
  }
  else return set_fail(c);
}

Context bind_class_occurrences_(Context c, class_names) { // alternative method name to ensure it is called
  Env res = ();
  for (class_name <- class_names) {
    if ("<class_name>" in c.env) {
      res = res + ("<class_name>" : c.env["<class_name>"]);
    } else {
      <r, c> = fresh_atom(c);
      c = sto_override(c, ( r : null_value() ));
      res = res + ("<class_name>" : ref(r));
    }
  }
  return set_result(c, envlit(res));
}

Context declare_global_method((MethodDecl) 
	`public <Type T> <Identifier ID> ( <FormalList? FLs> ) { 
	'  <VarDecl* VDs> <Statement* Ss> return <Expression E> ;
	'}`, Context c0) {
    <r, c0> = fresh_atom(c0); // required for recursion
	clos = closure(Context(Context local_c) {
	  return in_environment(local_c, c0.env, Context(Context local_c) {
	    if (listlit([*ARGS]) := get_given(local_c)) {
	      local_c = match_formals(local_c, formal_list(FLs), ARGS);
          if(!local_c.failed && envlit(args_map) := get_result(local_c)) {
	        local_c = declare_variables(local_c, [VD | VD <- VDs]);	
		    if (!local_c.failed && envlit(local_map) := get_result(local_c)) {
		      return in_environment(local_c, ("<ID>" : ref(r)) + args_map + local_map, Context(Context local_c) {
		        return eval(exec(local_c, [ s | s <- Ss] ), E);
		      });
		    }
	        else return set_fail(local_c);
          }
          else return set_fail(local_c);
	    }
	    else return set_fail(local_c);
	  });
	});
    c0 = sto_override(c0, (r : clos));
	return set_result(c0, envlit( ("<ID>":ref(r)) ));
}

Context eval(Context c0, (Expression) `<Identifier ID> ( <ExpressionList? ELs> )`) {
 c = c0;
 try {
   if(ref(r) := c.env["<ID>"] && closure(clos) := c.sto[r]) {
       c = evaluate_actuals(c, actuals(ELs));
       if(!c.failed && listlit(ARGS) := get_result(c)) {
         return with_given(c, listlit(ARGS), clos);
       }
       else return set_fail(c);
    }
    else return set_fail(c);
  }
  catch: {
    // the code below seems to reveal a bug in Rascal?
    // return eval(c0, (Expression) `this.<Identifier ID> ( <ExpressionList? ELs> )`);
    return set_fail(c);
  }
}