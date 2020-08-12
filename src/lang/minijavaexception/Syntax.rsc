module lang::minijavaexception::Syntax

extend lang::minijavarepl::Syntax;

syntax MethodDecl = "public" Type Identifier id "(" FormalList? ")" Throws "{"
                       VarDecl* Statement* "return" Expression ";" 
                     "}";
                     
syntax Throws
  = "throws" { ExceptionType "," }+;
  
syntax ExceptionType = Identifier;

syntax Statement
  = "throw" Expression ";";