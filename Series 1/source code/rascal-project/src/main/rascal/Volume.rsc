module Volume

import Utilitary;
import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;

int totalNoOfLinesWithComments = 0;


int countCodeLines(list[Declaration] asts) {
    int totalNoOfLines = 0;
    int commentLines = 0;
    int blankLines = 0;
    int codeLines = 0;
    int totalNoCodeLines = 0;
    for (ast <- asts) {
        list[str] lines = readFileLines(ast.src);
        for (str line <- lines) {
            totalNoOfLines += 1; 
            if (isShortCommentLine(line) || isLongComment(line))  {
                commentLines += 1;
            } else if (isBlankLine(line)){
                blankLines += 1;
            }
            else{
                codeLines += 1;
            }
            totalNoCodeLines += 1;
        }
    } 
    printVolume(totalNoCodeLines, commentLines, blankLines, codeLines);
    return codeLines; 
}

void printVolume(int totalNoCodeLines, int commentLines, int blankLines, int codeLines){
    println("Volume: LOC");
    println("• Total lines: <totalNoCodeLines>");
    println("• Comment lines: <commentLines>");
    println("• Blank lines: <blankLines>");
    println("• LOC: <codeLines>");
}

