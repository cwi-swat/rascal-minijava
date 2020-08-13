module lang::minijava::MiniJavaREPL

import IO;
import List;
import String;

import Content;
import bacata::REPL;
import bacata::Notebook;

import lang::minijavaexception::Syntax;
import lang::minijavaexception::Interpreter;
import lang::minijavarepl::AuxiliarySyntax;


import lang::html5::DOM;

NotebookServer getMiniJavaNotebook(bool debug = false) {
	k = kernel("MiniJava", |home:///Documents/ResearchProjects/rascal-minijava/src/|, "lang::minijava::MiniJavaREPL::myMiniJavaREPl", salixPath=|home:///salix/src|);
	return createNotebook(k, debug = debug);
}

REPL myMiniJavaREPl() {

	Program miniJavaParser(str input) {
		try {
			return load(input);
		} catch e: {
			println("Parse error: <e>");
			return (Program)``;
		}
	}
	
	Context miniJHandler(Program p, Context c) {
		try {
			Context newC = exec(p, c);
			return newC;
		} catch e: {
			c.out = c.out + "<e>";
			return set_fail(c);
		}
	}
	
	Content miniJPrinter(Context old, Context current) {
		str result = "";
		if (no_failure() := current.failed) {
			list[str] resList = drop(size(old.out), current.out);
		
			list[HTML5Node] children = [ p(s) | str s <- resList, s != "\n"];
			result = toString(div(children));
		} else {
			HTML5Node res = div(p(("Something went wrong. " | it + "<s>\n" | str s <- current.out,  s != "\n"), 
				 HTML5Attr::style("color:red")));
			result = deescape(toString(res));
		}
		return html(replaceAll(result, "\n", ""));
	}
	
	Completion miniJavaCompletor(str line, int cursor, Context config)
		= <0, [ e | e <- config.env, startsWith(e, line) ]>;

	return repl2(parser = miniJavaParser, newHandler = miniJHandler, initConfig = empty_context(), printer = miniJPrinter, completor = miniJavaCompletor);
}
