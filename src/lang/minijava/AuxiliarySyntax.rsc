module lang::minijava::AuxiliarySyntax

alias Env = map[str,Val];
alias Sto = map[Ref,Val];
alias Out = list[str];

data Context = ctx(Env env, Sto sto, int seed, Out out, Val given, bool failed, Val res);

data Val = ref(Ref r) 
         | intlit(int i) 
         | boollit(bool b) 
         | vec(list[Ref] vec)
         | envlit(Env e)
         | listlit(list[value] l)
         | closure(Closure closure)
         | classlit(Class class)
         | objectlit(Object obj)
         | null_value();
          
alias Ref     = int;
alias Closure = Context(Context);
data Class    = class(Closure cons, Env members, list[str] parents);
data Object   = object(int id, str class_name, Env fields, list[Object] parents);  

Context empty_context() {
  Env env = ();
  Sto sto = ();
  return ctx(env, sto, 0, [], null_value(), false, null_value());
} 

Context in_environment(Context c, Env env, Context(Context) body) {
  c2 = body(ctx(c.env + env, c.sto, c.seed, c.out, c.given, c.failed, c.res));
  return ctx(c.env, c2.sto, c2.seed, c2.out, c.given, c2.failed, c2.res);
}

Context sto_override(Context c, Sto sto) = ctx(c.env, c.sto + sto, c.seed, c.out, c.given, c.failed, c.res);

tuple[Ref, Context] fresh_atom(Context c) = <c.seed, ctx(c.env, c.sto, c.seed + 1, c.out, c.given, c.failed, c.res)>;

Context append_output(Context c, Out out) = ctx(c.env, c.sto, c.seed, c.out + out, c.given, c.failed, c.res);

Context with_given(Context c, Val given, Context(Context) body) {
  c2 = body(ctx(c.env, c.sto, c.seed, c.out, given, c.failed, c.res));
  return ctx(c.env, c2.sto, c2.seed, c2.out, c.given, c2.failed, c2.res);
}
Val get_given(Context c) {
  return c.given;
}

Context set_fail(Context c) {
  return ctx(c.env, c.sto, c.seed, c.out, c.given, true, null_value());
}

Val get_result(Context c) = c.res;
Context set_result(Context c, Val res) = ctx(c.env, c.sto, c.seed, c.out, c.given, c.failed, res);