module lang::minijava::Interpreter

import lang::std::Layout;

import lang::minijava::Syntax;
import lang::minijava::AuxiliarySyntax;

import util::Maybe;
import String;
import List;
import IO;

Context exec(Program p) = exec(p, empty_context());
Context exec(Program p, Context c) {
  return do_main(c, p);
}

Context do_main(Context c, (Program)
    `class <Identifier ID1> { 
 	'  public static void main ( String[] <Identifier ID2> ) { 
 	'    <Statement S> 
 	'  }
 	'} <ClassDecl* CDs>`) {
   c = class_sequence(c, CDs);
   if (!c.failed && envlit(env) := get_result(c)) {
     return in_environment(c, env, Context(Context c) {    
       return exec(c, S);
     });
   }
   else return set_fail(c);	
} 

// classes
Context class_sequence(Context c, CDs) {
  c = bind_class_occurrences(c, class_occurrences(CDs));
  if (!c.failed && envlit(env) := get_result(c)) {
    return in_environment(c, env, Context(Context local_c) {
      return declare_classes(local_c, CDs);
    });
  }
  else return set_fail(c);
}
    
Context bind_class_occurrences(Context c, class_names) {
  Env res = ();
  for (class_name <- class_names) {
    <r, c> = fresh_atom(c);
    c = sto_override(c, ( r : null_value() ));
    res = res + ("<class_name>" : ref(r));
  }
  return set_result(c, envlit(res));
}

set[str] class_occurrences(d) {
    set[str] res = {};
    top-down visit(d) {
       case (Expression) `new <Identifier ID> ()` : {
         res = res + {"<ID>"};
       }
       case (ClassDecl) `class <Identifier ID1>  {
                        '    <VarDecl* VDs> <MethodDecl* MDs>  
                        '}` : {
         res = res + {"<ID1>"};               
       }     
       case (ClassDecl) `class <Identifier ID1> extends <Identifier ID2> {
                        '    <VarDecl* VDs> <MethodDecl* MDs>  
                        '}` : {
         res = res + {"<ID1>"};               
       }
    };
    return res;
  }

Context declare_classes(Context c, ClassDecl CD) = declare_class(c, CD);
Context declare_classes(Context c, ClassDecl* CDs) = declare_classes(c, [ CD | CD <- CDs]);
Context declare_classes(Context c, []) = set_result(c, envlit(()));
Context declare_classes(Context c, [CD, *CDs]) {
  c = declare_class(c, CD);
  if (!c.failed && envlit(env1) := get_result(c)) {
      c =  declare_classes(c, CDs);
      if (!c.failed && envlit(env2) := get_result(c)) {
        return set_result(c, envlit(env1 + env2));
      }
      else return set_fail(c);
  }
  else return set_fail(c);
}

Context declare_class(Context c, (ClassDecl) 
  `class <Identifier ID> extends <Identifier ID2> {
  '    <VarDecl* VDs> <MethodDecl* MDs>  
  '}`) = declare_class(c,ID,VDs,MDs,just("<ID2>")); 
Context declare_class(Context c, (ClassDecl) 
  `class <Identifier ID>  {
  '    <VarDecl* VDs> <MethodDecl* MDs>  
  '}`) = declare_class(c,ID,VDs,MDs,nothing()); 

Context declare_class(Context c, ID, VDs, MDs, Maybe[str] mID2) {
  c = declare_class_val(c, ID, VDs, MDs, mID2);
  if (!c.failed && classlit(class_val) := get_result(c)) {
    try {
	    if(ref(r) := c.env["<ID>"]) {
	  	  return set_result(sto_override(c, ( r : classlit(class_val) )), envlit(( "<ID>" : ref(r))));
	    }
	    else return set_fail(c);
	}    
	catch exc: {print(exc); return set_fail(c);}
  }
  else return set_fail(c);
}

Context declare_class_val(Context c, ID, VDs, MDs, Maybe[str] mID2) {
  cons = Context(Context local_c) {
    <obj_id, local_c> = fresh_atom(local_c);
    local_c = declare_variables(local_c,VDs);
    if (!c.failed && envlit(field_map) := get_result(local_c)) {
      list[Object] parents = [];
      if (just(ID2) := mID2) {
        try {
          if (ref(r) := local_c.env["<ID2>"]) {
            if (classlit(pc) := local_c.sto[r]) {
              local_c = pc.cons(local_c);
              if(!local_c.failed && objectlit(po) := get_result(local_c))
                parents = [po];
              else
                return set_fail(c);
            }
            else return set_fail(c);
          }
          else return set_fail(c);
        }
        catch exc: {print(exc); return set_fail(c);}
      }
      return set_result(local_c, objectlit(object(obj_id, "<ID>", field_map, parents)));
    }
    else return set_fail(c);
  };
  c = declare_methods(c,MDs);
  if (!c.failed && envlit(method_map) := get_result(c)) {
	  class_val = class(cons,method_map,[]);
	  if (just(ID2) := mID2)
	    class_val = class(cons,method_map,["<ID2>"]);
      return set_result(c, classlit(class_val));
  }
  else return set_fail(c);
}


// methods
Context declare_methods(Context c, MethodDecl* MDs) = declare_methods(c, [ MD | MD <- MDs]);
Context declare_methods(Context c, []) = set_result(c, envlit(()));
Context declare_methods(Context c, [MD, *MDs]) {
  c = declare_method(c, MD);
  if (!c.failed && envlit(env1) := get_result(c)) {
    c =  declare_methods(c, MDs);
    if (!c.failed && envlit(env2) := get_result(c)) {
        return set_result(c, envlit(env1 + env2));
    }
    else return set_fail(c);
  }
  else return set_fail(c);
}
Context declare_method(Context c0, (MethodDecl) 
	`public <Type T> <Identifier ID> ( <FormalList? FLs> ) { 
	'  <VarDecl* VDs> <Statement* Ss> return <Expression E> ;
	'}`) {
	clos = closure(Context(Context local_c) {
	  return in_environment(local_c, c0.env, Context(Context local_c) {
	    if (listlit([objectlit(obj), *ARGS]) := get_given(local_c)) {
	      <r, local_c> = fresh_atom(local_c);
	      local_c = sto_override(local_c, (r : objectlit(obj)));
	      local_c = match_formals(local_c, formal_list(FLs), ARGS);
          if(!local_c.failed && envlit(args_map) := get_result(local_c)) {
	        local_c = retrieve_fields(local_c, obj);
	        if(!local_c.failed && envlit(fields_map) := get_result(local_c)) { 
		        local_c = declare_variables(local_c, [VD | VD <- VDs]);	
		        if (!local_c.failed && envlit(local_map) := get_result(local_c)) {
		          return in_environment(local_c, ("this" : ref(r)) + args_map + fields_map + local_map, Context(Context local_c) {
		            return eval(exec(local_c, [ s | s <- Ss] ), E);
		          });
		        }
		        else return set_fail(local_c);
		    }
	        else return set_fail(local_c);
          } 
          else return set_fail(local_c);
	    }
	    else return set_fail(local_c);
	  });
	});
	return set_result(c0, envlit( ("<ID>":clos) ));
}

Context match_formals(Context c, [], []) = set_result(c, envlit(()));
Context match_formals(Context c, [ID, *IDs], [A, *As]) {
  <r, c> = fresh_atom(c);
  c = sto_override(c, ( r : A ));
  c = match_formals(c, IDs, As);
  if (!c.failed && envlit(env) := get_result(c)) {
    return set_result(c, envlit(("<ID>":ref(r)) + env));
  }
  else return set_fail(c);
}
default Context match_formals(c, Xs, Ys) = set_fail(c);

list[str] formal_list([]) = [];
list[str] formal_list([FL]) = formal_list(FL);
list[str] formal_list(opt(FL)) = formal_list(FL);
list[str] formal_list(FormalList? FLs) = [ x | FL <- FLs, x <- formal_list(FL)];
list[str] formal_list((FormalList) `<Type T> <Identifier ID>`) = ["<ID>"];
list[str] formal_list((FormalList)`<Type T> <Identifier ID> , <FormalList FLs>`) = ["<ID>"] + formal_list(FLs);

Context retrieve_fields(Context c, obj) {
  p_env = obj.fields;
  for (par <- obj.parents) {
    c = retrieve_fields(c, par);
    if (!c.failed && envlit(env) := get_result(c)) {
      p_env = p_env + env;
    }
    else return set_fail(c);
  }
  return set_result(c, envlit(p_env));
}

Context declare_variables(Context c, VarDecl* VDs) = declare_variables(c, [ VD | VD <- VDs]);
Context declare_variables(Context c, []) = set_result(c, envlit(()));
Context declare_variables(Context c, [(VarDecl) `<Type T> <Identifier ID>;`,*Vs]) {
  <r, c> = fresh_atom(c);
  c = sto_override(c, (r : initial_value(T)));
  c = declare_variables(c, Vs);
  if (!c.failed && envlit(env) := get_result(c)) {
    return set_result(c, envlit(("<ID>" : ref(r)) + env));
  }
  else return set_fail(c);
}

Val initial_value((Type) `int[]`) = vec([]);
Val initial_value((Type) `boolean`) = boollit(false);
Val initial_value((Type) `int`) = intlit(0);
Val initial_value((Type) `<Identifier ID>`) = null_value();

// statements
// TODO array assignment	
Context exec(Context c, (Statement) `{ <Statement* Stmts> }`) = exec(c, [ s | s <- Stmts ]);
Context exec(Context c, []) = set_result(c, null_value());
Context exec(Context c, [S, *Ss]) {
  c = exec(c, S);
  if (!c.failed && null_value() := get_result(c)) {
    return exec(c, Ss);
  }
  else return set_fail(c);
}
Context exec(Context c, (Statement) `<Identifier ID> = <Expression E>;`) {
  c = eval(c, E);
  try    {
    if (!c.failed && ref(r) := c.env["<ID>"]) {
      return set_result(sto_override(c, ( r  : get_result(c) )), null_value());
    }
    else return set_fail(c);
  }
  catch exc: {print(exc); return set_fail(c);} 
}
Context exec(Context c, (Statement) `<Identifier ID> [ <Expression E1> ] = <Expression E2>;`) {
  c = eval(c, E1);
  if (!c.failed && intlit(n) := get_result(c)) {
    try {
      if (ref(r) := c.env["<ID>"] && vec(V) := c.sto[r]) {
        c = eval(c, E2);
        if (!c.failed) {
          return set_result(sto_override(c, ( V[n] : get_result(c))), null_value());
        } else return set_fail(c);
      }else return set_fail(c);
    }
    catch exc: { print exc; return set_fail(c);}  
  }
  else return set_fail(c);
}
Context exec(Context c, (Statement) `System.out.println(<Expression E>);`) {
  c = eval(c, E);
  if (!c.failed)
    return set_result(append_output(c, [to_string(get_result(c)), "\n"]), null_value());
  return c;
}
Context exec(Context c, (Statement) `while( <Expression E> ) <Statement S>`) {
  b = true;
  while(b) {
    c = eval(c, E);
    if (!c.failed && boollit(b2) := get_result(c)) {
      b = b2;
      if (b) {
        c = exec(c, S);
        if (c.failed) return c;
      }
    }
    else return set_fail(c);
  }
  return set_result(c, null_value());
}
Context exec(Context c, (Statement) `if ( <Expression E> ) <Statement S1> else <Statement S2>`) {
  c = eval(c, E);
  if(!c.failed && boollit(b) := get_result(c)) {
    if (b) return exec(c, S1);
    else   return exec(c, S2);
  }
  else return set_fail(c);
}

// expressions
Context eval(Context c, (Expression) `<Identifier ID>`) {
  try    if (ref(r) := c.env["<ID>"]) return set_result(c, c.sto[r]); 
         else return set_fail(c);
  catch exc: {print(exc); return set_fail(c);}
}
Context eval(Context c, (Expression) `this`) {
  try    {
    if (ref(r) := c.env["this"]) {
      return set_result(c, c.sto[r]);
    }else return set_fail(c);
  }
  catch exc: {print(exc); return set_fail(c);}
}
Context eval(Context c, (Expression) `(<Expression E>)`) = eval(c, E);
Context eval(Context c, (Expression) `<Integer I>`) = set_result(c, intlit(toInt("<I>")));
Context eval(Context c, (Expression) `true`) = set_result(c, boollit(true));
Context eval(Context c, (Expression) `false`) = set_result(c, boollit(false));
Context eval(Context c, (Expression) `!<Expression E>`) {
	c = eval(c, E);
	if (boollit(b) := get_result(c)) {
	  return set_result(c, boollit(!b));
	}
	return set_fail(c);
}
Context eval(Context c, (Expression) `<Expression E1> && <Expression E2>`) {
  c = eval(c, E1);
  if (!c.failed && boollit(b1) := get_result(c)) {
    if(!b1) return set_result(c, boollit(false));
    c = eval(c, E2);
    if (!c.failed && boollit(b2) := get_result(c)) {
      return c;
    }
    return set_fail(c);
  } 
  return set_fail(c);
}
Context eval(Context c, (Expression) `<Expression E1> \< <Expression E2>`) {
  c = eval(c, E1); 
  if (!c.failed && intlit(x) := get_result(c)) {
    c = eval(c,E2);
    if (!c.failed && intlit(y) := get_result(c))
      return set_result(c, boollit(x < y));
    else return set_fail(c);
  }
  else
    return set_fail(c);
}
Context eval(Context c, (Expression) `<Expression E1> + <Expression E2>`) {
  c = eval(c, E1); 
  if (!c.failed && intlit(x) := get_result(c)) {
    c = eval(c, E2);
    if (!c.failed && intlit(y) := get_result(c)) {
      return set_result(c, intlit(x + y));
    }
    else return set_fail(c);
  }
  else
    return set_fail(c);
}
Context eval(Context c, (Expression) `<Expression E1> - <Expression E2>`) {
  c = eval(c, E1); 
  if (!c.failed && intlit(x) := get_result(c)) {
	  c = eval(c,E2);
	  if (!c.failed && intlit(y) := get_result(c))
	    return set_result(c, intlit(x - y));
	  else return set_fail(c);
  }else return set_fail(c);
}
Context eval(Context c, (Expression) `<Expression E1> * <Expression E2>`) {
  c = eval(c, E1); 
  if(!c.failed && intlit(x) := get_result(c)) {
	  c = eval(c, E2);
	  if (!c.failed && intlit(y) := get_result(c))
	    return set_result(c, intlit(x * y));
	  else
	    return set_fail(c);  
  }
  else return set_fail(c);
}
Context eval(Context c, (Expression) `new int [ <Expression E1> ]`) {
  c = eval(c, E1); 
  if (!c.failed && intlit(x) := get_result(c)) {
    res = [];
    for(int _ <- [0..x]) {
      <r, c> = fresh_atom(c);
      c = sto_override(c, ( r : intlit(0) ));
      res = res + r;
    }
    return set_result(c, vec(res));
  }
  else
    return set_fail(c);
}
Context eval(Context c, (Expression) `new <Identifier ID>()`) {
  try{
	  if (ref(r) := c.env["<ID>"]) {
	    if(classlit(cl) := c.sto[r]) {
	       return cl.cons(c);
	    }
	    else return set_fail(c);
	  }
	  else return set_fail(c);
  } catch exc: {print(exc); return set_fail(c);}
}
Context eval(Context c, (Expression) `<Expression E>.<Identifier ID> ( <ExpressionList? ELs> )`) {
  c = eval(c, E);
  if (!c.failed && objectlit(obj) := get_result(c)) {
    try {
      c = compute_class_members(c, obj.class_name);
      if(!c.failed && envlit(member_map) := get_result(c)) {
        if(closure(clos) := member_map["<ID>"]) {
           c = evaluate_actuals(c, actuals(ELs));
           if(!c.failed && listlit(ARGS) := get_result(c)) {
             return with_given(c, listlit([objectlit(obj)] + ARGS), clos);
           }
           else return set_fail(c);
        }
        else return set_fail(c);
      }
      else return set_fail(c);
    }
    catch exc: {print(exc); return set_fail(c);}
  }
  else return set_fail(c);
}
Context eval(Context c, (Expression) `<Expression E1> [ <Expression E2> ]`) {
  c = eval(c, E2);
  if (!c.failed && intlit(x) := get_result(c)) { 
	  c = eval(c, E1);
	  if (vec(y) := get_result(c)) {
	    try    return set_result(c, c.sto[y[x]]);
	    catch exc: {print(exc); return set_fail(c);}
	  }
	  else
	    return set_fail(c);
  } return set_fail(c);
}
Context eval(Context c, (Expression) `<Expression E1> . length`) {
  c = eval(c, E1);
  if (!c.failed && vec(x) := get_result(c)) {
    return set_result(c, intlit(size(x)));
  }
  else
    return set_fail(c);
}

Context compute_class_members(Context c, str class_name) {
  try {
    if (ref(r) := c.env[class_name] && classlit(cl) := c.sto[r]) {
      sub_map = cl.members;
      if ([parent_name] := cl.parents) {
         c = compute_class_members(c, parent_name);
         if (!c.failed && envlit(sup_map) := get_result(c)) {
           return set_result(c, envlit(sup_map + sub_map));
         }
         else return set_fail(c);
      }
      else return set_result(c, envlit(sub_map));
    }
    else return set_fail(c);
  }
  catch exc: {print(exc); return set_fail(c);}
}

list[Expression] actuals(ExpressionList? ELs) = actuals([ E | E <- ELs ]);
list[Expression] actuals([]) = [];
list[Expression] actuals([(ExpressionList) `<Expression E>`]) = [ E ]; 
list[Expression] actuals([(ExpressionList) `<Expression E>, <ExpressionList EL>`]) = [E] + actuals([EL]); 

Context evaluate_actuals(Context c, []) = set_result(c, listlit([]));
Context evaluate_actuals(Context c, [Expression E, *Es]) {
  c = eval(c, E);
  if (!c.failed) {
    Val val = get_result(c);
    c = evaluate_actuals(c, Es);
    if (!c.failed && listlit(ARGS) := get_result(c)) {
      return set_result(c, listlit(val + ARGS));
    }
    else return set_fail(c);
  }
  else return set_fail(c);
}

str to_string(ref(n)) = "ref@<n>";
str to_string(intlit(n)) = "<n>";
str to_string(boollit(b)) = "<b>";
str to_string(null_value()) = "null";
str to_string(V) = print("<V>");

data OptEnv = Some(Env e) | Empty();
