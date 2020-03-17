module lang::minijavarepl::Interpreter

import lang::minijavarepl::AuxiliarySyntax;
import lang::minijava::Syntax;
import lang::minijavarepl::Syntax;
import lang::minijava::Interpreter;

import lang::std::Layout;

import util::Maybe;
import IO;

Context exec(Program p) = exec(p, empty_context());
Context exec((Program) `<Phrase* phrases>`, Context c) = ( c | phrase_decl(phrase, it) | phrase <- phrases );
	
Context phrase_decl((Phrase) `<Expression E> ;`, Context c) = phrase_decl((Phrase) `System.out.println(<Expression E>);`, c);
Context phrase_decl((Phrase) `<Statement S>`, Context c) = exec(c, S);
Context phrase_decl((Phrase) `<ClassDecl CD>`, Context c) = accumulate(phrase_class(c, CD));
Context phrase_decl((Phrase) `<VarDecl VD>`, Context c) = accumulate(declare_variables(c, [VD]));

Context accumulate(Context c) {
  if (!c.failed && envlit(env) := get_result(c)) {
    return env_override(c, env);
  }
  else return set_fail(c);
}

Context phrase_class(Context c, ClassDecl CD) {
  c = bind_class_occurrences(c, class_occurrences(CD));
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

Context bind_class_occurrences(Context c, class_names) {
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