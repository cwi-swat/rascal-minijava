module lang::minijava::tests::FunconTranslation

import lang::minijava::Syntax;
import lang::minijava::FunconTranslation;

import lang::funcons::ToFCT;

import String;

import IO;

public void main(){
  for (loc l <- |project://rascal-minijava/examples/|.ls, endsWith(l.file,".minijava")) 
    generateFCT_file(l);
}

public void generateFCT_file(loc l) {
  l_fct = l.parent + (l.file + ".fct");
  println(l_fct);
  program = load(l);
  writeFile(l_fct, toFCT(sem(program))());
}