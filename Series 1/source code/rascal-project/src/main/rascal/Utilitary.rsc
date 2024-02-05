module Utilitary
import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;


str getVolumeThreshold(int volume) {
    str res =  
        (volume <= 66) ? "++" :
        (volume <= 246) ? "+" :
        (volume <= 665) ? "o" :
        (volume <= 1310) ? "-" :
        "--";
    println("SCORE: " + res + "\n");
    return res;
}

str getAssertRatioThreshold(real assertRatio) {
    str res = 
        (assertRatio < 0.01) ? "--" : 
        (assertRatio < 0.03) ? "-" : 
        (assertRatio < 0.05) ? "o" : 
        (assertRatio < 0.5) ? "+" : 
        "++";
    println("SCORE: " + res + "\n");
    return res;
}

str getUnitSizeThreshold(map[str, real] riskMap) {
    str res = 
        (riskMap["moderate"] <= 50 && riskMap["high"] <= 0 && riskMap["very high"] <= 0) ? "++" :
        (riskMap["low"] >= 56.3 && riskMap["moderate"] <= 43.7 && riskMap["high"] <= 22.3 && riskMap["very high"] <= 6.9) ? "+" :
        (riskMap["moderate"] <= 40 && riskMap["high"] <= 10 && riskMap["very high"] <= 0) ? "o" :
        (riskMap["moderate"] <= 18 && riskMap["high"] <= 20 && riskMap["very high"] <= 35) ? "-" :
        "--";
    println("SCORE: " + res + "\n");
    return res;
}


str getDuplicationThreshold(real duplicationPercentage) {
    str res = 
        (duplicationPercentage <= 3.0) ? "++" :
        (duplicationPercentage <= 5.0) ? "+" :
        (duplicationPercentage <= 10.0) ? "o" :
        (duplicationPercentage <= 20.0) ? "-" :
        "--";
    println("SCORE: " + res + "\n");
    return res;
}


str getSystemComplexityRatingBasedOnCC(map[str, real] riskMap) {
    str res = 
        (riskMap["moderate"] <= 25 && riskMap["high"] <= 0 && riskMap["very high"] <= 0) ? "++" :
        (riskMap["moderate"] <= 30 && riskMap["high"] <= 5 && riskMap["very high"] <= 0) ? "+" :
        (riskMap["moderate"] <= 40 && riskMap["high"] <= 10 && riskMap["very high"] <= 0) ? "o" :
        (riskMap["moderate"] <= 50 && riskMap["high"] <= 15 && riskMap["very high"] <= 5) ? "-" :
        "--";
    println("SCORE: " + res + "\n");
    return res;
}

map[str, real] getRiskFootPrintPercentage(map[str, int] riskToVolume, int volume){
    map[str, real] complexityRiskFootPrint = ();
    for (str key <- riskToVolume){
        complexityRiskFootPrint[key] ? 0 += toReal(riskToVolume[key])/toReal(volume)*100;
    }
    return complexityRiskFootPrint; 
}

list[Declaration] getASTs(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation); 
    list[Declaration] asts = [createAstFromFile(f, true)
        | f <- files(model.containment), isCompilationUnit(f)]; 
      
    return asts;
}

bool isAssertStatementCall(str line){
    return /assert.*/ := line;
}

int getNrOfCodeLinesPerSource(loc source){
    int totalNoOfLines = 0;
    int commentLines = 0;
    int blankLines = 0;
    int codeLines = 0;
    list[str] lines = readFileLines(source);

    for (str line <- lines) {
        totalNoOfLines += 1; 
        if (!isShortCommentLine(line) && !isBlankLine(line) && !isLongComment(line))  {
            codeLines += 1;
        } 
    }
    return codeLines;
}

bool isLongComment(str line){
    return /^\s*\/\*.*|^\s*\*.*|.*\*\/\s*$/ := line;
}

bool isShortCommentLine(str line) {
    return /^\s*\/\// := line;
}

bool isBlankLine(str line) {
    return /^\s*$/ := line; 
}