module Main

import Volume;
import CyclomaticComplexity;
import Utilitary;
import UnitSize;
import Duplication;
import UnitTestCoverage;
import Scoring;
import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;


list[loc] getASTlocations(loc projectLocation) {
    M3 model = createM3FromMavenProject(projectLocation);
    list[loc] asts = [f | f <- files(model.containment), isCompilationUnit(f)];
    return asts;
}


int main(){
    println("TEST FOR THE SMALLSQL\n");
    loc path = |home:///smallsql0.21_src|;
    map[str, str] complexityRankings = getCompleteRatings(path);
    map[str, str] aggregateMaint = aggregateMaintainability(complexityRankings);
    printMaintainability(complexityRankings, aggregateMaint);

    println("\n\n\nTEST FOR THE HSQLDB\n");

    path = |home:///hsqldb-2.3.1/hsqldb-2.3.1|; // this one runs more time because of the duplication function (2-5 min)
    complexityRankings = getCompleteRatings(path);
    aggregateMaint = aggregateMaintainability(complexityRankings);
    printMaintainability(complexityRankings, aggregateMaint);
    return 0;
}

