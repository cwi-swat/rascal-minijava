module lang::minijavarepl::IMSOS

import lang::iml::Operations;
import Type;
import lang::minijavarepl::AbstractSyntax;

data Context = ctx(value env,value sto,value seed,value out,value res);
Context empty_context() {
  return ctx(map_empty(),map_empty(),0,list_nil(),-1);
}
Context eval1(Context ctx, lit(V)) {
  ctx.res = V;
  return ctx;
}
Context eval1(Context ctx, length(E)) {
  ctx = eval1(ctx,E);
  if(V := ctx.res) {
    ctx.res = size(V);
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, tt()) {
  ctx.res = true;
  return ctx;
}
Context eval1(Context ctx, ff()) {
  ctx.res = false;
  return ctx;
}
Context eval1(Context ctx, ref(Id)) {
  Gam = ctx.env;
  Sig = ctx.sto;
  if(R := map_lookup(Gam , Id)) {
    if(V := map_lookup(Sig , R)) {
      ctx.env = Gam;
      ctx.sto = Sig;
      ctx.res = V;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, new_array(E)) {
  ctx = eval1(ctx,E);
  if(N := ctx.res) {
    ctx = eval1(ctx,new_references(N,0));
    if(V := ctx.res) {
      ctx.res = V;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, new_references(N,D)) {
  if(true := int_leq(N , 0)) {
    ctx.res = list_nil();
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, new_references(N,D)) {
  if(true := int_geq(N , 1)) {
    if(N2 := pred(N)) {
      ctx = eval1(ctx,new_reference(D));
      if(V := ctx.res) {
        ctx = eval1(ctx,new_references(N2,D));
        if(Vs := ctx.res) {
          ctx.res = list_cons(V , Vs);
          return ctx;
        } else { fail; }
      } else { fail; }
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, new_reference(D)) {
  S0 = ctx.seed;
  Sig0 = ctx.sto;
  if(S1 := succ(S0)) {
    if(Sig1 := map_insert(S1 , D , Sig0)) {
      ctx.seed = S1;
      ctx.sto = Sig1;
      ctx.res = S1;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, not(E)) {
  ctx = eval1(ctx,E);
  if(V := ctx.res) {
    ctx.res = bool_neg(V);
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, mult(P,Q)) {
  ctx = eval1(ctx,P);
  if(V1 := ctx.res) {
    ctx = eval1(ctx,Q);
    if(V2 := ctx.res) {
      ctx.res = int_product(V1 , V2);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, plus(P,Q)) {
  ctx = eval1(ctx,P);
  if(V1 := ctx.res) {
    ctx = eval1(ctx,Q);
    if(V2 := ctx.res) {
      ctx.res = int_sum(V1 , V2);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, minus(P,Q)) {
  ctx = eval1(ctx,P);
  if(V1 := ctx.res) {
    ctx = eval1(ctx,Q);
    if(V2 := ctx.res) {
      ctx.res = int_subtract(V1 , V2);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, less_than(P,Q)) {
  ctx = eval1(ctx,P);
  if(V1 := ctx.res) {
    ctx = eval1(ctx,Q);
    if(V2 := ctx.res) {
      ctx.res = int_less_than(V1 , V2);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, and(P,Q)) {
  ctx = eval1(ctx,P);
  if(V1 := ctx.res) {
    ctx = eval1(ctx,Q);
    if(V2 := ctx.res) {
      ctx.res = bool_and(V1 , V2);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, if_then_else(E,S1,_)) {
  ctx = eval1(ctx,E);
  if(true := ctx.res) {
    ctx = eval1(ctx,S1);
    if(V := ctx.res) {
      ctx.res = V;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, if_then_else(E,_,S2)) {
  ctx = eval1(ctx,E);
  if(false := ctx.res) {
    ctx = eval1(ctx,S2);
    if(V := ctx.res) {
      ctx.res = V;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, while_loop(E,S)) {
  ctx = eval1(ctx,E);
  if(true := ctx.res) {
    ctx = eval1(ctx,S);
    if(_ := ctx.res) {
      ctx = eval1(ctx,while_loop(E,S));
      if(V := ctx.res) {
        ctx.res = V;
        return ctx;
      } else { fail; }
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, while_loop(E,S)) {
  ctx = eval1(ctx,E);
  if(false := ctx.res) {
    ctx.res = done();
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, print(E)) {
  Alp0 = ctx.out;
  ctx.out = Alp0;
  ctx = eval1(ctx,E);
  Alp1 = ctx.out;
  if(V := ctx.res) {
    ctx.out = list_append(Alp1 , V);
    ctx.res = done();
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, assign(I,E)) {
  Gam = ctx.env;
  Sig0 = ctx.sto;
  ctx.env = Gam;
  ctx.sto = Sig0;
  ctx = eval1(ctx,E);
  Gam = ctx.env;
  Sig1 = ctx.sto;
  if(V := ctx.res) {
    if(R := map_lookup(Gam , I)) {
      if(Sig2 := map_insert(R , V , Sig1)) {
        ctx.env = Gam;
        ctx.sto = Sig2;
        ctx.res = done();
        return ctx;
      } else { fail; }
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, array_assign(I,P,Q)) {
  Gam = ctx.env;
  Sig0 = ctx.sto;
  if(R := map_lookup(Gam , I)) {
    if(A := map_lookup(Sig0 , R)) {
      ctx.env = Gam;
      ctx.sto = Sig0;
      ctx = eval1(ctx,P);
      Gam = ctx.env;
      Sig1 = ctx.sto;
      if(N := ctx.res) {
        if(R2 := index(A , N)) {
          ctx.env = Gam;
          ctx.sto = Sig1;
          ctx = eval1(ctx,Q);
          Gam = ctx.env;
          Sig2 = ctx.sto;
          if(V := ctx.res) {
            if(Sig3 := map_insert(R2 , V , Sig2)) {
              ctx.env = Gam;
              ctx.sto = Sig3;
              ctx.res = done();
              return ctx;
            } else { fail; }
          } else { fail; }
        } else { fail; }
      } else { fail; }
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, seq(S1,S2)) {
  ctx = eval1(ctx,S1);
  if(_ := ctx.res) {
    ctx = eval1(ctx,S2);
    if(V := ctx.res) {
      ctx.res = V;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, vardecl(Ty,Id)) {
  Gam = ctx.env;
  ctx = eval2(ctx,Ty);
  if(V := ctx.res) {
    ctx.env = Gam;
    ctx = eval1(ctx,new_reference(V));
    Gam = ctx.env;
    if(R := ctx.res) {
      ctx.env = Gam;
      ctx.res = map_singleton(Id , R);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, close(S)) {
  Gam = ctx.env;
  ctx.res = closure(Gam,S);
  return ctx;
}
Context eval2(Context ctx, "int") {
  ctx.res = 0;
  return ctx;
}
Context eval1(Context ctx, method(Nm,Body)) {
  Gam = ctx.env;
  if(Clo := closure(Gam,Body)) {
    ctx.env = Gam;
    ctx = eval1(ctx,new_reference(Clo));
    Gam = ctx.env;
    if(R := ctx.res) {
      ctx.env = Gam;
      ctx.res = map_singleton(Nm , R);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, scope(D,S)) {
  Gam0 = ctx.env;
  ctx.env = Gam0;
  ctx = eval1(ctx,D);
  Gam0 = ctx.env;
  if(Gam1 := ctx.res) {
    ctx.env = map_union(Gam0 , Gam1);
    ctx = eval1(ctx,S);
    Gam2 = ctx.env;
    if(V := ctx.res) {
      ctx.env = Gam0;
      ctx.res = V;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, accumulate(D1,D2)) {
  Gam0 = ctx.env;
  ctx.env = Gam0;
  ctx = eval1(ctx,D1);
  Gam0 = ctx.env;
  if(Gam1 := ctx.res) {
    ctx.env = Gam1;
    ctx = eval1(ctx,D2);
    Gam1 = ctx.env;
    if(Gam2 := ctx.res) {
      ctx.env = Gam0;
      ctx.res = map_union(Gam0 , Gam1);
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, phrase_vardecl(D)) {
  ctx = eval1(ctx,D);
  if(Gam := ctx.res) {
    ctx.res = Gam;
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, phrase_method_decl(D)) {
  ctx = eval1(ctx,D);
  if(Gam := ctx.res) {
    ctx.res = Gam;
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, phrase_stmt(S)) {
  ctx = eval1(ctx,S);
  if(_ := ctx.res) {
    ctx.res = map_empty();
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, phrase_seq(D1,D2)) {
  Gam0 = ctx.env;
  ctx.env = Gam0;
  ctx = eval1(ctx,D1);
  Gam0 = ctx.env;
  if(Gam1 := ctx.res) {
    ctx.env = map_union(Gam0 , Gam1);
    ctx = eval1(ctx,D2);
    Gam1 = ctx.env;
    if(Gam2 := ctx.res) {
      ctx.env = Gam0;
      ctx.res = map_union(Gam0 , map_union(Gam1 , Gam2));
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, phrase_skip()) {
  ctx.res = map_empty();
  return ctx;
}
Context eval1(Context ctx, V) {
  if(true := is_value(V)) {
    ctx.res = V;
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, closure(Gam,S)) {
  ctx.res = closure(Gam,S);
  return ctx;
}
Context eval1(Context ctx, done()) {
  ctx.res = done();
  return ctx;
}
