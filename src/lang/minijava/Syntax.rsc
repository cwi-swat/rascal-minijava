module lang::minijava::Syntax

extend lang::std::Layout;

import IO;
import ParseTree;

//layout MyLayout = [\t\n\ \r\f]*;
lexical Integer = [0-9]+ !>> [0-9];
lexical Letter = [a-zA-Z];
lexical Identifier = ID \ Keywords;
lexical ID = Letter IdChar* !>> [A-Za-z0-9_] ;
lexical IdChar = (Letter | [0-9] | [_]);

keyword Keywords = "String" | "System" | "boolean"
				 | "class"
                 | "else"
                 | "extends"
                 | "false"
                 | "if"
                 | "int"
                 | "length"
               | "main"
               | "new"
               | "out"
               | "println"
               | "public"
               | "return"
               | "static"
               | "this"
               | "true"
               | "void";

start syntax Expression
	= Integer
	| Expression "." "length"
	| "true"
	| "false"
	| Identifier
	| "this"
	| "new" "int" "[" Expression "]"
	| "new" Identifier "(" ")"
	| bracket "(" Expression ")"
	> left (Expression "[" Expression "]" 
           |Expression "." Identifier "(" ExpressionList? ")")
	> "!" Expression
	> left Expression "*" Expression
	> left (Expression "+" Expression
	       |Expression "-" Expression)
	> non-assoc Expression "\<" Expression
	> left Expression "&&" Expression
	;
	
syntax ExpressionList
	= left Expression ( "," ExpressionList )?
	;
	
syntax Statement 
	= "{" Statement* "}"
	| "if" "(" Expression ")" Statement "else" Statement
	| "while" "(" Expression ")" Statement
	| "System" "." "out" "." "println" "(" Expression ")" ";"
	| Identifier "=" Expression ";"
	| Identifier "[" Expression "]" "=" Expression ";"
	;
	
syntax FormalList = Type Identifier ( "," FormalList )?;

syntax Type = "int" "[" "]" | "boolean" | "int" | Identifier;

syntax MethodDecl = "public" Type Identifier "(" FormalList? ")" "{"
                       VarDecl* Statement* "return" Expression ";" 
                     "}";
syntax VarDecl = Type Identifier ";";

syntax ClassDecl = "class" Identifier ( "extends" Identifier )? "{"
                     VarDecl* MethodDecl*  
                    "}";
                    
syntax MainClass = "class" Identifier "{" 
                      "public" "static" "void" "main" "(" "String" "[" "]" Identifier ")" "{"
                         Statement
                      "}"
                    "}";
                  
syntax Program = Standard MainClass ClassDecl* Standard;


//MethodDecl load(str s) = parse(#MethodDecl, s, allowAmbiguity = true);
//Statement load(str s) = parse(#Statement, s);
//Expression load(str s) = parse(#Expression, s);
Program load(str s) = parse(#Program, s);
Program load(loc f) = parse(#Program, f);
