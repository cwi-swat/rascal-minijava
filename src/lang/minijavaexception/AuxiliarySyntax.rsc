module lang::minijavaexception::AuxiliarySyntax

extend lang::minijava::AuxiliarySyntax;

data FailureType
  = exception(str msg)
  ;
  