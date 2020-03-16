module lang::minijava::MiniJavaREPL

import Map;
import List;
import String;

import bacata::REPL;
import bacata::Notebook;

import lang::minijavarepl::Syntax;
//import lang::minijava::Syntax;
//import lang::minijava::Interpreter;
import lang::minijavarepl::Interpreter;
//import lang::minijava::AuxiliarySyntax;
import lang::minijavarepl::AuxiliarySyntax;


import lang::html5::DOM;

NotebookServer getNB(bool debug = false) {
	k = kernel("MiniJava", |home:///Documents/ResearchProjects/rascal-minijava/src/|, "lang::minijava::MiniJavaREPL::myMiniJavaREPl", salixPath=|home:///salix/src|);
	return createNotebook(k, debug = debug);
}

REPL myMiniJavaREPl() {
	Context miniJHandler(str input, Context c) {
		try {
			Program p = load(input);
			Context newC = exec(p, c);
			return newC;
		} catch e: {
			return set_fail(c, ["<e>"]);
		}
	}
	
	CommandResult miniJPrinter(Context old, Context current) {
		str result = "";
		//if (!current.failed && !isEmpty(current.out)) {			
		if (!current.failed) {
			list[str] resList = drop(size(old.out), current.out);
		
			list[HTML5Node] children = [ p(s) | str s <- resList, s != "\n"];
			result = toString(div(children));
		} else {
			HTML5Node res = div(p(("Something went wrong. " | it + "<s>\n" | str s <- current.out,  s != "\n"), 
				 HTML5Attr::style("color:red")));
			result = deescape(toString(res));
		}
		return commandResult(replaceAll(result, "\n", ""));
	}
	
	Completion miniJavaCompletor(str line, int cursor, Context config)
		= <0, [ e | e <- config.env, startsWith(e, line) ]>;

	return replization(miniJHandler, empty_context(), miniJPrinter, miniJavaCompletor);
}
