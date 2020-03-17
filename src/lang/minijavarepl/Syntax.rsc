module lang::minijavarepl::Syntax

extend lang::minijava::Syntax;
                  
syntax Phrase = Expression ";" | Statement | VarDecl | ClassDecl | MethodDecl;
                  
syntax Program = Standard Phrase* Standard;

syntax Expression = Identifier "(" ExpressionList? ")";

Program load(str s) = parse(#Program, s);
Program load(loc f) = parse(#Program, f);