module lang::minijavarepl::tests::InterpreterException

import IO;
import String;

import lang::minijavarepl::Syntax;
import lang::minijavarepl::AuxiliarySyntax;
import lang::minijavarepl::Interpreter;


void main() {
  for (loc l <- |project://rascal-minijava/examples/exceptions|.ls, endsWith(l.file,".minijava")) main(l);
}

void main(loc l) {
  l_output = l.parent + (l.file + ".output");
  program = load(l);
  c = exec(program);
  println("<c>");
  res = "";
  if (no_failure() := c.failed) {
    res = "";
    for (str s <- c.out) {
      res += "<s>\n";
    }
  }
  else {
  	for (str s <- c.out) {
      res += "<s>\n";
    }
  	res += "<c>\n";
  		
  }
  writeFile(l_output, res);
}