module lang::minijavaexception::Interpreter

extend lang::minijavarepl::Interpreter;

import lang::minijavarepl::AuxiliarySyntax;
import lang::minijava::Syntax;
import lang::minijavarepl::Syntax;
import lang::minijavaexception::Syntax;

import util::Maybe;
import IO;

Context declare_global_method((MethodDecl) 
	`public <Type T> <Identifier ID> ( <FormalList? FLs> ) <Throws exc> { 
	'  <VarDecl* VDs> <Statement* Ss> return <Expression E> ;
	'}`, Context c0) {
    <r, c0> = fresh_atom(c0); // required for recursion
	clos = closure(Context(Context local_c) {
	  return in_environment(local_c, c0.env, Context(Context local_c) {
	    if (listlit([*ARGS]) := get_given(local_c)) {
	      local_c = match_formals(local_c, formal_list(FLs), ARGS);
          if(no_failure() := local_c.failed && envlit(args_map) := get_result(local_c)) {
	        local_c = declare_variables(local_c, [VD | VD <- VDs]);	
		    if (no_failure() := local_c.failed && envlit(local_map) := get_result(local_c)) {
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
	return set_output(set_result(c0, envlit( ("<ID>":ref(r)) )), "created method <ID>(<FLs>)");
}