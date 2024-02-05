module Volume

import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;
import Relation; 
import Type;
import DateTime;
import lang::java::m3::TypeSymbol;
import util::UUID;
import Node;
import util::Math;
import Boolean;
import lang::json::IO;

import Utils;

// checks if the line is a blank comment
bool isComment(str line){
    return /^\s*\/\*.*|^\s*\*.*|.*\*\/\s*$|^\s*\/\/.*/ := line;
}

// check if the line is a blank line
bool isBlankLine(str line) {
    return /^\s*$/ := line; 
}

// compute volume given source location
int volume(loc location){
    list [Declaration] asts = getASTsList(location); 
    int commentLines = 0;
    int blankLines = 0;
    int codeLines = 0;
    for (ast <- asts) {
        list[str] lines = readFileLines(ast.src);
        for (str line <- lines) {
            if (isComment(line))  {
                commentLines += 1;
            } else if (isBlankLine(line)){
                blankLines += 1;
            }
            else{
                codeLines += 1;
            }
        }
    } 
	return codeLines; 
}

// function to print the volume
void printVolume(int totalNoCodeLines, int commentLines, int blankLines, int codeLines){
    println("Volume: LOC");
    println("• Total lines: <totalNoCodeLines>");
    println("• Comment lines: <commentLines>");
    println("• Blank lines: <blankLines>");
    println("• LOC: <codeLines>");
}


int getVolumePerSource(loc source){
    int totalNoOfLines = 0;
    int commentLines = 0;
    int blankLines = 0;
    int codeLines = 0;
    list[str] lines = readFileLines(source);

    for (str line <- lines) {
        totalNoOfLines += 1; 
        if (!isComment(line) && !isBlankLine(line))  {
            codeLines += 1;
        } 
    }
    return codeLines;
}