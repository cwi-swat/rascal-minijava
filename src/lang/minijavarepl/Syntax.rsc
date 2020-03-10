module lang::minijavarepl::Syntax

import lang::minijava::Syntax;
                  
syntax Phrase = Expression ";"? | Statement | VarDecl | ClassDecl;
                  
syntax Program = Standard Phrase* Standard;

Program load(str s) = parse(#Program, s);
Program load(loc f) = parse(#Program, f);