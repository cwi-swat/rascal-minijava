module lang::minijavarepl::Syntax

extend lang::minijava::Syntax;

extend lang::std::Layout;

syntax Program = Standard Phrase Standard;
                  
syntax Phrase = Expression ";" | Statement | VarDecl | ClassDecl | MethodDecl | assoc Phrase Phrase;

syntax Expression = Identifier "(" ExpressionList? ")";

Program load(str s) = parse(#Program, s);
Program load(loc f) = parse(#Program, f);