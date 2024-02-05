module Utils

import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import util::Math;
import Type;
import DateTime;
import util::Math;


loc defaultLocation = |unresolved:///|;

// Formats the content from a cloned file for display.
public str formatContentFromClone(loc fileLocation) {
    str escapedBackslashes = replaceAll(readFile(fileLocation), "\\", "\\\\");
    str escapedQuotes = replaceAll(escapedBackslashes, "\"", "\\\"");
    // Replace tabs with non-breaking spaces for formatting
    str replacedTabs = replaceAll(escapedQuotes, "\t", "&nbsp;&nbsp;&nbsp;&nbsp;"); 
    str formattedNewlines = replaceAll(replacedTabs, "\r\n", "\<br/\>"); 
    return formattedNewlines;
}

// Extracts the source location from an AST subtree.
loc extractLocationFromNode(node astSubTree) {
    if (Declaration declNode := astSubTree) { 
        if (declNode@src?) {
            return declNode@src;
        }
    } else if (Expression exprNode := astSubTree) {
        if (exprNode@src?) {
            return exprNode@src;
        }
    } else if (Statement stmtNode := astSubTree) {
        if (stmtNode@src?) {
            return stmtNode@src;
        }
    }
	return defaultLocation;
}

// Retrieves a list of ASTs from a given project location.
list[Declaration] getASTsList(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation); 
    list[Declaration] asts = [createAstFromFile(f, true)
        | f <- files(model.containment), isCompilationUnit(f)];      
    return toList(toSet(asts));
}