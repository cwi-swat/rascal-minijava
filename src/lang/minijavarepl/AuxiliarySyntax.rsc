module lang::minijavarepl::AuxiliarySyntax

extend lang::minijava::AuxiliarySyntax;

Context env_override (Context c, Env env) = ctx(c.env + env, c.sto, c.seed, c.out, c.given, c.failed, c.res);

Class class_override(Class c1, Class c2) {
  new_cons = Context(Context c) {
    c = c1.cons(c);
    if (no_failure() := c.failed && objectlit(obj1) := get_result(c)) {
      c = c2.cons(c);
      if (no_failure() := c.failed && objectlit(obj2) := get_result(c)) {
        <obj_id, c> = fresh_atom(c);
        object_val = object(obj_id, obj1.class_name, obj2.fields + obj1.fields, obj1.parents + obj2.parents);
        return set_result(c, objectlit(object_val));
      } else return set_fail(c);
    } else return set_fail(c);
  };
  return class(new_cons, c2.members + c1.members, c2.parents + c1.parents);
}