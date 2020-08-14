module lang::minijavarepl::Syntax

extend lang::minijavaexception::Syntax;

extend lang::std::Layout;

import ParseTree;
import lang::minijava::Syntax;

syntax Program = Standard Phrase Standard;
                  
syntax Phrase = Statement | VarDecl | ClassDecl | MethodDecl | assoc Phrase Phrase;

syntax Statement = Expression ";";

syntax Expression = Identifier "(" ExpressionList? ")";

Program load(str s) = parse(#Program, s);
Program load(loc f) = parse(#Program, f);