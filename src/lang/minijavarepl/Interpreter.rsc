module lang::minijavarepl::Interpreter

import lang::minijavarepl::AuxiliarySyntax;
import lang::minijava::Syntax;
import lang::minijavarepl::Syntax;
import lang::minijava::Interpreter;

import lang::std::Layout;

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
    return declare_classes(env_override(c, env), CD);
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