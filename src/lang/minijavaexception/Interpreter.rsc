module lang::minijavaexception::Interpreter

extend lang::minijava::Interpreter;

import lang::minijavaexception::Syntax;
import lang::minijavaexception::AuxiliarySyntax;


Context catch_exceptions(Context c) {
	if (failure(exception(msg)) := c.failed) 
		return  set_exception(set_output(c, msg), no_failure());
	else
		return c;	
}

Context set_exception(Context c, Exception e)
	= ctx(c.env, c.sto, c.seed, c.out, c.given, e, c.res);


Context create_bindings(Context c) {
// check if there's always a result
  <r, c> = fresh_atom(c);
  c = sto_override(c, (r : get_result(c)));
  return set_result(c, envlit(("ss<r>" : ref(r))));
}

Context collect_bindings(Context c) {
  if (envlit(new) := get_result(c)) {
    c.env = c.env + new;
  }
  return c;
}

Context set_output(Context c, str output) {
  c.out += [output];
  return c;
}

Context set_output(Context c) {
	if (envlit(new) := get_result(c)) {
		for(key <- new) {
			Val val = c.sto[c.env[key].r];
			return set_output(c, "<key> ==\> <val>");
		}
	}
	return c;
}