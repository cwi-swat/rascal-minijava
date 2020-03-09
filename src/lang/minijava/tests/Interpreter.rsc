module lang::minijava::tests::Interpreter

import lang::minijava::Syntax;
import lang::minijava::AuxiliarySyntax;
import lang::minijava::Interpreter;

import String;

import IO;

void main() {
  for (loc l <- |project://rascal-minijava/examples|.ls, endsWith(l.file,".minijava")) {
    l_output = l.parent + (l.file + ".output");
    println(l);
	  program = load(l);
	  c = exec(program);
	  res = "";
	  if (!c.failed) {
	    res = "";
	    for (str s <- c.out) {
	      res += s;
	    }
	  }
	  else res = "<c>";
	  writeFile(l_output, res);
  }
}

