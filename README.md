# rascal-minijava
Rascal implementation of the MiniJava subset of Java

Currently provides:

* syntax (concrete), module `lang::minijava::Syntax`
* dynamic semantics (purely functional definitional interpreter), module `lang::minijava::Interpreter`, tested by `lang::minijava::tests::Interpreter`
* a funcon translation, module `lang::minijava::FunconTranslation`, tested by `lang::minijava::tests::FunconTranslation`

The tests use the example programs in `examples/` which are also valid Java programs. 
The semantic descriptions provided by the definitional interpreter and by the funcon translation for the (unextended) minijava language should match the semantics of Java.
