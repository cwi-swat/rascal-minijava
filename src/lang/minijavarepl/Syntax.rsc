module lang::minijavarepl::Syntax

extend lang::minijava::Syntax;

import lang::std::Layout;
                  
syntax Phrase = Expression ";" | Statement | VarDecl | ClassDecl | MethodDecl | assoc (Phrase Phrase);
                  
syntax Expression = Identifier "(" ExpressionList? ")";

syntax Program = Standard Phrase Standard;

Program load(str s) = parse(#Program, s);
Program load(loc f) = parse(#Program, f);