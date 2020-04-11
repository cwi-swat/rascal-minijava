module lang::minijavarepl::IMSOSTranslation

import lang::minijavarepl::Syntax;
import lang::minijavarepl::AbstractSyntax;

import String;
import Layout;

phrase simplify((Program) `<Phrase* phrases>`) = ( phrase_skip() | phrase_seq(it, simplify(phrase)) | phrase <- phrases );
	
phrase simplify((Phrase) `<Expression E> ;`) = simplify((Phrase) `System.out.println(<Expression E>);`);
phrase simplify((Phrase) `<Statement S>`) = phrase_stmt(simplify(S));
phrase simplify((Phrase) `<VarDecl VD>`) = phrase_vardecl(simplify(VD));
phrase simplify((Phrase) `<MethodDecl MD>`) = phrase_method_decl(simplify(MD));

list[vardecl] simplify((VarDecl*) VDs) = ( [] | simplify(VD) + it | VD <- VDs);
vardecl simplify((VarDecl) `<Type T> <Identifier ID>;`) = vardecl("<T>", "<ID>");

stmt simplify((Statement) `{ <Statement* Stmts> }`) = ( done() | seq(simplify(Stmt), it) | Stmt <- Stmts);
stmt simplify((Statement) `<Identifier ID> = <Expression E>;`) = assign("<ID>", simplify(E));
stmt simplify((Statement) `<Identifier ID> [ <Expression E1> ] = <Expression E2>;`) = array_assign("<ID>", simplify(E1), simplify(E2));
stmt simplify((Statement) `System.out.println(<Expression E>);`) = print(simplify(E));
stmt simplify((Statement) `if ( <Expression E> ) <Statement S1> else <Statement S2>`) = if_then_else(simplify(E), simplify(S1), simplify(S2));
stmt simplify((Statement) `while( <Expression E> ) <Statement S>`) = while_loop(simplify(E), simplify(S));

expr simplify((Expression) `<Identifier ID>`) = ref("<ID>");
expr simplify((Expression) `this`) = ref("this");
expr simplify((Expression) `(<Expression E>)`) = simplify(E);
expr simplify((Expression) `<Integer I>`) = lit(toInt("<I>"));
expr simplify((Expression) `true`) = tt();
expr simplify((Expression) `false`) = ff();
expr simplify((Expression) `!<Expression E>`) = not(simplify(E));
//TODO
expr simplify((Expression) `<Expression E1> * <Expression E2>`) = mult(simplify(E1), simplify(E2));
//TODO
expr simplify((Expression) `<Expression E1> + <Expression E2>`) = plus(simplify(E1), simplify(E2));

method_decl simplify((MethodDecl) 
	`public <Type T> <Identifier ID> ( <FormalList? FLs> ) { 
	'  <VarDecl* VDs> <Statement* Ss> return <Expression E> ;
	'}`) = method("<ID>", simplify(FLs), simplify(VDs), ( done() | seq(it, simplify(S)) | S <- Ss), simplify(E));
	
list[vardecl] simplify([]) = [];
list[vardecl] simplify([FL]) = formal_list(FL);
list[vardecl] simplify(opt(FL)) = formal_list(FL);
list[vardecl] simplify(FormalList? FLs) = [ x | FL <- FLs, x <- formal_list(FL)];
list[vardecl] simplify((FormalList) `<Type T> <Identifier ID>`) = [vardecl("<T>", "<ID>")];
list[vardecl] simplify((FormalList)`<Type T> <Identifier ID> , <FormalList FLs>`) = [vardecl("<T>", "<ID>")] + formal_list(FLs);

