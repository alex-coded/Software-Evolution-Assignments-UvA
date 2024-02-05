module Duplication

import Utilitary; 
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;

real duplication(list[Declaration] asts, int volume) {
    println("Duplication:");
    list[str] codeBlocks = getCodeBlocks(asts); 
    println("• Total lines: <volume>");

    real duplicates = checkDuplication(codeBlocks); 
    real res = (duplicates / size(codeBlocks)) * 100.0;
    println("• Num of LOC: " + ": (<round(res)>%)<(duplicates)>");
    return res;
}

list[str] getCodeBlocks(list[Declaration] asts) {
    list[str] codeBlocks = [];
    for (ast <- asts) {
        list[str] filteredLines = getFilteredLines(ast);
        for (int i <- [0 .. (size(filteredLines) - 6)]) {
            list[str] codeBlockLines = filteredLines[i..i + 6];
            str codeBlock = concatenateLines(codeBlockLines);
            codeBlocks += codeBlock; 
        }
    }

    return codeBlocks;
}

list[str] getFilteredLines(Declaration ast) {
    list[str] filteredLines = [];

    for (str line <- readFileLines(ast.src)) {
        if (!isShortCommentLine(line) && !isBlankLine(line) && !isLongComment(line)) {
            line = trim(line); 
            if (!isBlankLine(line)) {
                filteredLines += line;
            }
        }
    }

    return filteredLines;
}

str concatenateLines(list[str] lines) {
    str concatenated = "";
    for (str line <- lines) {
        concatenated += line;
    }
    return concatenated;
}

real checkDuplication(list[str] codeBlocks) {
    real duplicates = 0.0;
    list[str] duplicatedCodeBlocks = [];

    for (str codeBlock <- codeBlocks) {
        if (codeBlock in duplicatedCodeBlocks) {
            duplicates += 2; 
        } else {
            duplicatedCodeBlocks += codeBlock;
        }
    }

    return duplicates;
}

