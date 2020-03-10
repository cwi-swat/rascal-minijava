module lang::minijavarepl::AuxiliarySyntax

extend lang::minijava::AuxiliarySyntax;

Context env_override (Context c, Env env) = ctx(c.env + env, c.sto, c.seed, c.out, c.given, c.failed, c.res);