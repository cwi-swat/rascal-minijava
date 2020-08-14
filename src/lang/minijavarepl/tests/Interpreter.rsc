module lang::minijavarepl::tests::Interpreter

import IO;
import String;

import lang::minijavarepl::Syntax;
import lang::minijavarepl::AuxiliarySyntax;
import lang::minijavarepl::Interpreter;


void main() {
  for (loc l <- |project://rascal-minijava/examples/repl|.ls, endsWith(l.file,".minijava")) main(l);
  for (loc l <- |project://rascal-minijava/examples/class-override|.ls, endsWith(l.file,".minijava")) main(l);
}

void main(loc l) {
  l_output = l.parent + (l.file + ".output");
  println(l);
  program = load(l);
  c = exec(program);
  res = "";
  if (no_failure() := c.failed) {
    res = "";
    for (str s <- c.out) {
      res += s;
    }
  }
  else res = "<c>";
  writeFile(l_output, res);
}