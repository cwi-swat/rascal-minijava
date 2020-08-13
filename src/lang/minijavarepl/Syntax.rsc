module lang::minijavarepl::Syntax

extend lang::minijava::Syntax;

extend lang::std::Layout;

import ParseTree;

syntax Program = Phrase;
                  
syntax Phrase = Expression ";" | Statement | VarDecl | ClassDecl | MethodDecl | assoc Phrase Phrase;

syntax Expression = Identifier "(" ExpressionList? ")";

Program load(str s) = parse(#Program, s);
Program load(loc f) = parse(#Program, f);