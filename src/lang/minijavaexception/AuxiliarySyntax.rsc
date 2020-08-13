module lang::minijavaexception::AuxiliarySyntax

extend lang::minijavarepl::AuxiliarySyntax;

data ExceptionType
  = exception(str msg)
  ;