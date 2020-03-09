module lang::minijava::FunconTranslation

import lang::std::Layout;

import lang::minijava::Syntax;
import lang::funcons::Funcons;

import IO;

Funcons sem(Program p) = 
  initialise_binding_(initialise_storing_(initialise_giving_(finalise_failing_(run(p)))));

Funcons run((Program) 
	`class <Identifier ID1> { 
 	'  public static void main ( String[] <Identifier ID2> ) { 
 	'    <Statement S> 
 	'  }
 	'} <ClassDecl* CDs>`) 
 	= scope_(class_sequence(CDs), execute(S));
	
Funcons class_sequence(CDs) = recursive_(bound_names(CDs), declare_classes(CDs));

Funcons bound_names(ClassDecl* decls) = set_([bound_name(cd) | cd <- decls]);
Funcons bound_name((ClassDecl) 
	`class <Identifier ID1> { <VarDecl* _> <MethodDecl* _> }`) 
	= id("<ID1>");
Funcons bound_name((ClassDecl)
	`class <Identifier ID1> extends <Identifier _> { <VarDecl* _> <MethodDecl* _> }`)
    = id("<ID1>");
	
Funcons declare_classes(ClassDecl* decls) = collateral_([declare_class(cd) | cd <- decls]);
Funcons declare_class((ClassDecl) 
	`class <Identifier ID1> { <VarDecl* VDs> <MethodDecl* MDs> }`) 
	= map_(tuple_(id("<ID1>"), class_ (thunk_ (closure_ (reference_ (object_ (
		 fresh_atom_(), id("<ID1>"), declare_variables(VDs))))),
		 declare_methods(MDs))));
Funcons declare_class((ClassDecl) 
	`class <Identifier ID1> extends <Identifier ID2> { <VarDecl* VDs> <MethodDecl* MDs> }`) 
	= map_(tuple_(id("<ID1>"), class_ (thunk_ (closure_ (reference_ (object_ (
		 fresh_atom_(), id("<ID1>"), declare_variables(VDs),
		   dereference_(force_(class_instantiator_(bound_(id("<ID2>"))))))))),
		 declare_methods(MDs),
		 id("<ID2>"))));

Funcons declare_variables(VarDecl* VDs) = collateral__([ declare_variable(VD) | VD <- VDs]);
Funcons declare_variable((VarDecl)
    `<Type T> <Identifier ID> ;`)
    = map_(tuple_(id("<ID>"), allocate_initialised_variable_(type_of(T), initial_value(T))));
 
Funcons type_of((Type) `int[]`) = vectors_(variables_());
Funcons type_of((Type) `boolean`) = booleans_();
Funcons type_of((Type) `int`) = integers_();
Funcons type_of((Type) `<Identifier ID>`) = pointers_(objects_());

Funcons initial_value((Type) `int[]`) = vector_();
Funcons initial_value((Type) `boolean`) = false_();
Funcons initial_value((Type) `int`) = literal("0");
Funcons initial_value((Type) `<Identifier ID>`) = pointer_null_();

Funcons methods() = functions_(tuples_(references_(objects_()), star_(values_())), value_());

Funcons declare_methods(MethodDecl* MDs) = collateral_([ declare_method(MD) | MD <- MDs ]);
Funcons declare_method((MethodDecl) 
	`public <Type T> <Identifier ID> ( <FormalList? FLs> ) { 
	'  <VarDecl* VDs> <Statement* Ss> return <Expression E> ;
	'}`) = map_(tuple_(id("<ID>"), function_ (closure_ (scope_ (
	       collateral_ (
	          match_ ( given_(),
	             tuple_ (
	               [pattern_ (abstraction_ (map_ (tuple_ (
	                 id("this"), allocate_initialised_variable_ (pointers_(objects_()), given_())))))] +
	               bind_formals(FLs))),
	           object_single_inheritance_feature_map_(
	             checked_(dereference_(first_(tuple_elements_(given_()))))),
	           declare_variables(VDs)),
	         sequential__(execute_all(Ss) + [evaluate(E)]))))));

list[Funcons] bind_formals([]) = [];
list[Funcons] bind_formals([FL]) = bind_formals(FL);
list[Funcons] bind_formals(opt(FL)) = bind_formals(FL);
list[Funcons] bind_formals(FormalList? FLs) = [ x | FL <- FLs, x <- bind_formals(FL)];
list[Funcons] bind_formals((FormalList)
  `<Type T> <Identifier ID>`)
  = bind_formals(T,ID);
list[Funcons] bind_formals((FormalList)
  `<Type T> <Identifier ID> , <FormalList FLs>`)
  = bind_formals(T,ID) + bind_formals(FLs);
list[Funcons] bind_formals(Type T, Identifier ID) = 
  [pattern_(abstraction_(map_(tuple_(
     id("<ID>"), allocate_initialised_variable_(type_of(T), given_())))))];
default Funcons bind_formals(n) = println(n);

list[Funcons] execute_all(Statement* Stmts) = [ execute(S) | S <- Stmts ]; 
Funcons execute((Statement)
  `{ <Statement* Stmts> }`)
  = sequential__(execute_all(Stmts));
Funcons execute((Statement) 
  `if ( <Expression E> ) <Statement S1> else <Statement S2>`) 
  = if_true_else_( evaluate(E), execute(S1), execute(S2) );
Funcons execute((Statement) 
  `while ( <Expression E> ) <Statement S>`)
  = while_true_( evaluate(E), execute(S) );
Funcons execute((Statement)
  `System.out.println(<Expression E>);`)
  = print_(to_string_ (evaluate(E)), literal("\"\\n\""));
Funcons execute((Statement)
  `<Identifier ID> = <Expression E>;`)
  = assign_ (bound_ (id("<ID>")), evaluate(E));
Funcons execute((Statement)
  `<Identifier ID> [ <Expression E1> ] = <Expression E2> ;`)
  = assign_ (checked_ (index_ (integer_add_ ( evaluate(E1), literal("1"))
                              ,vector_elements_ (assigned_ (bound_ (id("<ID>")))) ))
            ,evaluate(E2));
	
Funcons evaluate((Expression) 
  `<Expression E1> && <Expression E2>`)
  = if_true_else_( evaluate(E1), evaluate(E2), false_());
Funcons evaluate((Expression)
  `<Expression E1> \< <Expression E2>`)
  = integer_is_less_( evaluate(E1), evaluate(E2) );
Funcons evaluate((Expression)
  `<Expression E1> + <Expression E2>`)
  = integer_add_( evaluate(E1), evaluate(E2) );
Funcons evaluate((Expression)
  `<Expression E1> - <Expression E2>`)
  = integer_subtract_( evaluate(E1), evaluate(E2) );
Funcons evaluate((Expression)
  `<Expression E1> * <Expression E2>`)
  = integer_multiply_( evaluate(E1), evaluate(E2) );
Funcons evaluate((Expression)
  `<Expression E1> [ <Expression E2> ]`)
  = assigned_ (checked_ (index_ ( integer_add_ ( evaluate(E2), literal("1")),
      vector_elements_ (evaluate(E1)))));
Funcons evaluate((Expression) 
  `<Expression E>.length`)
  = length_( vector_elements_ (evaluate(E)));
Funcons evaluate((Expression)
  `<Expression E>.<Identifier ID> ( <ExpressionList? ELs> )`)
  = give_(evaluate(E),
      apply_ (lookup_ (
         class_name_single_inheritance_feature_map_ (
            object_class_name_ (checked_(dereference_(given_())))),
         id("<ID>")),
        tuple_ ( [given_()] + evaluate_actuals(ELs))));
Funcons evaluate((Expression)
  `<Integer I>`) = literal("<I>");
Funcons evaluate((Expression) `true`) = true_();
Funcons evaluate((Expression) `false`) = false_();
Funcons evaluate((Expression) `<Identifier ID>`) = assigned_ (bound_ (id("<ID>")));
Funcons evaluate((Expression) `this`) = assigned_ (bound_ (id("this")));
Funcons evaluate((Expression) 
  `new int[<Expression E>]`) 
  = vector_ (interleave_repeat_ (allocate_initialised_variable_ ( integers_(), literal("0"))
                                ,literal("1"), evaluate(E)));
Funcons evaluate((Expression)
  `new <Identifier ID> ()`)
  = force_ (class_instantiator_(bound_(id("<ID>"))));
Funcons evaluate((Expression)
  `!<Expression E>`) = not_(evaluate(E));
Funcons evaluate((Expression)
  `(<Expression E>)`) = evaluate(E);
	
list[Funcons] evaluate_actuals(ExpressionList? ELs ) = [ x | E <- ELs, x <- evaluate_actuals(E) ];
list[Funcons] evaluate_actuals((ExpressionList)
  `<Expression E>`)
  = [evaluate(E)];
list[Funcons] evaluate_actuals((ExpressionList)
  `<Expression E> , <ExpressionList EL>`) = evaluate(E) + evaluate_actuals(EL);	

Funcons id(str s) = ident("<s>");