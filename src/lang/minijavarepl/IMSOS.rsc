module lang::minijavarepl::IMSOS

import Type;
import lang::minijavarepl::AbstractSyntax;
import lang::iml::operations;

data Context = ctx(value env,value store,value out,value signal_cnt,value signal_brk,value res);
Context empty_context() {
  return ctx(map-empty(),map-empty(),nil(),none(),none(),-1);
}
Context eval1(Context ctx, while(E,C)) {
  Sig = ctx.store;
  ctx.env = Sig;
  ctx = eval4(ctx,E);
  _ = ctx.env;
  if(true := ctx.res) {
    ctx.store = Sig;
    ctx.res = seq(listen_cnt(C),while(E,C));
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, seq(C1,C2)) {
  ctx = eval1(ctx,C1);
  if(C1' := ctx.res) {
    ctx.res = seq(C1',C2);
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, seq(done(),C2)) {
  ctx.res = C2;
  return ctx;
}
Context eval1(Context ctx, assign(R,E)) {
  Sig1 = ctx.store;
  ctx.env = Sig1;
  ctx = eval4(ctx,E);
  _ = ctx.env;
  if(V := ctx.res) {
    if(Sig2 := map-insert(Sig1 , R , V)) {
      ctx.store = Sig2;
      ctx.res = done();
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval1(Context ctx, print(E)) {
  Sig = ctx.store;
  L1 = ctx.out;
  ctx.env = Sig;
  ctx = eval4(ctx,E);
  _ = ctx.env;
  if(V := ctx.res) {
    ctx.store = Sig;
    ctx.out = list-append(L1 , list(V));
    ctx.res = done();
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, while(E,C)) {
  Sig = ctx.store;
  ctx.env = Sig;
  ctx = eval4(ctx,E);
  _ = ctx.env;
  if(false := ctx.res) {
    ctx.store = Sig;
    ctx.res = done();
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, while(E,C)) {
  Sig = ctx.store;
  ctx.env = Sig;
  ctx = eval4(ctx,E);
  _ = ctx.env;
  if(true := ctx.res) {
    ctx.store = Sig;
    ctx.res = seq(C,while(E,C));
    return ctx;
  } else { fail; }
}
Context eval3(Context ctx, plus(E1,E2)) {
  ctx = eval4(ctx,E1);
  if(I1 := ctx.res) {
    ctx = eval4(ctx,E2);
    if(I2 := ctx.res) {
      if(I3 := integer-add(I1 , I2)) {
        ctx.res = I3;
        return ctx;
      } else { fail; }
    } else { fail; }
  } else { fail; }
}
Context eval3(Context ctx, leq(E1,E2)) {
  ctx = eval4(ctx,E1);
  if(I1 := ctx.res) {
    ctx = eval4(ctx,E2);
    if(I2 := ctx.res) {
      if(true := is-less-or-equal(I1 , I2)) {
        ctx.res = true;
        return ctx;
      } else { fail; }
    } else { fail; }
  } else { fail; }
}
Context eval3(Context ctx, leq(E1,E2)) {
  ctx = eval4(ctx,E1);
  if(I1 := ctx.res) {
    ctx = eval4(ctx,E2);
    if(I2 := ctx.res) {
      if(false := is-less-or-equal(I1 , I2)) {
        ctx.res = false;
        return ctx;
      } else { fail; }
    } else { fail; }
  } else { fail; }
}
Context eval3(Context ctx, ref(R)) {
  Sig = ctx.env;
  if(V := map-lookup(Sig , R)) {
    ctx.env = Sig;
    ctx.res = V;
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, continue()) {
  none() = ctx.signal_cnt;
  ctx.signal_cnt = cnt();
  ctx.res = done();
  return ctx;
}
Context eval1(Context ctx, listen_cnt(C1)) {
  none() = ctx.signal_cnt;
  ctx.signal_cnt = none();
  ctx = eval1(ctx,C1);
  none() = ctx.signal_cnt;
  if(C1' := ctx.res) {
    ctx.signal_cnt = none();
    ctx.res = listen_cnt(C1');
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, listen_cnt(done())) {
  ctx.res = done();
  return ctx;
}
Context eval1(Context ctx, listen_cnt(C1)) {
  none() = ctx.signal_cnt;
  ctx.signal_cnt = none();
  ctx = eval1(ctx,C1);
  cnt() = ctx.signal_cnt;
  if(C1' := ctx.res) {
    ctx.signal_cnt = none();
    ctx.res = done();
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, break()) {
  none() = ctx.signal_brk;
  ctx.signal_brk = brk();
  ctx.res = done();
  return ctx;
}
Context eval1(Context ctx, listen_brk(C1)) {
  none() = ctx.signal_brk;
  ctx.signal_brk = none();
  ctx = eval1(ctx,C1);
  none() = ctx.signal_brk;
  if(C1' := ctx.res) {
    ctx.signal_brk = none();
    ctx.res = listen_brk(C1');
    return ctx;
  } else { fail; }
}
Context eval1(Context ctx, listen_brk(done())) {
  ctx.res = done();
  return ctx;
}
Context eval1(Context ctx, listen_brk(C1)) {
  none() = ctx.signal_brk;
  ctx.signal_brk = none();
  ctx = eval1(ctx,C1);
  brk() = ctx.signal_brk;
  if(C1' := ctx.res) {
    ctx.signal_brk = none();
    ctx.res = done();
    return ctx;
  } else { fail; }
}
Context eval2(Context ctx, _X1) {
  ctx = eval1(ctx,_X1);
  if(_X2 := ctx.res) {
    ctx = eval2(ctx,_X2);
    if(_X3 := ctx.res) {
      ctx.res = _X3;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval4(Context ctx, _X5) {
  ctx = eval3(ctx,_X5);
  if(_X6 := ctx.res) {
    ctx = eval4(ctx,_X6);
    if(_X7 := ctx.res) {
      ctx.res = _X7;
      return ctx;
    } else { fail; }
  } else { fail; }
}
Context eval2(Context ctx, _X0) {
}
Context eval4(Context ctx, _X4) {
}
