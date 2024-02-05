module Scoring 

import Duplication;
import UnitSize;
import Volume;
import CyclomaticComplexity;
import Utilitary;
import UnitTestCoverage;
import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
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

//-----------------SCORING SUB-CHARACTERISTICS OF MAINTANABILITY------------------------

//scoring of the sub-characteristics of maintainability by aggregation

//analysability: volume, duplication, unit size
//changeability: complexity per unit, duplication
//testability: complexity per unit, unit size

map[str, str] getCompleteRatings(loc path) {
    int volume = countCodeLines(getASTs(path));
    map[str, str] rankings = (
        "VolumeRating": getVolumeThreshold(volume/1000), // divide to 1000 because we convert to KLOC
        "CCRating": calculateUnitComplexity(getASTs(path), volume),
        "UnitSizeRating": getUnitSizeThreshold(getUnitSize(getASTs(path), volume)),
        "DuplicationRating": getDuplicationThreshold(duplication(getASTs(path), volume)),
        "UnitTesting": getAssertRatioThreshold(unitTesting(getASTs(path), volume))
    );
    return rankings;
}

map[str, real] rankingScores = (
    "++": 4.0,
    "+": 3.0,
    "o": 2.0,
    "-": 1.0,
    "--": 0.0);


str getSubcharacteristic(map[str, str] rankings, map[str, real] scores, list[str] variableNames) {
    real totalWeightedScore = 0.0;
    int totalWeights = size(variableNames); 
    for (str variable <- variableNames) {
        if (variable in rankings) {
            real score = scores[rankings[variable]];
            totalWeightedScore += score;
        }
    }
    int subScore = round(totalWeightedScore / totalWeights);
    str finalRanking;
    if (subScore >= 4) {
        finalRanking = "++";
    } else if (subScore >= 3) {
        finalRanking = "+";
    } else if (subScore >= 2) {
        finalRanking = "o";
    } else if (subScore >= 1) {
        finalRanking = "-";
    } else {
        finalRanking = "--";
    }
    return finalRanking;
}



// -------------------AGGREGATING MAINTANABILITY-------------------------------

map[str, list[str]] components = (
    "analysability": ["VolumeRating", "DuplicationRating", "UnitSizeRating", "UnitTesting"],
    "changeability": ["CCRating", "DuplicationRating"],
    "stability": ["UnitTesting"],
    "testability": ["CCRating", "UnitSizeRating", "UnitTesting"]
);

map[str, str] aggregateMaintainability(map[str, str] ratingMap) {
    map[str, str] aggregation = (
        "analysability": getSubcharacteristic(ratingMap, rankingScores, components["analysability"]),
        "changeability": getSubcharacteristic(ratingMap, rankingScores, components["changeability"]),
        "stability": getSubcharacteristic(ratingMap, rankingScores, components["stability"]),
        "testability": getSubcharacteristic(ratingMap, rankingScores, components["testability"])
    );
    return aggregation;
}

void printMaintainability(map[str, str] complexityRankings, map[str, str] aggregateMaint){
    for (str key <- aggregateMaint){
        println(capitalize(key));
        for (str element <- components[key]){
            println("    • " + element + ": " + complexityRankings[element]);
        }
        println("OVERALL: " + aggregateMaint[key]);
        println();
    }
    println("----------------------");
    list[str] allMetrics = ["analysability", "changeability", "stability", "testability"];
    println("MAINTAINABILITY SCORE:");
    for (str element <- allMetrics){
            println("    • " + element + ": " + aggregateMaint[element]);
    }
    str maintanabilityScore = getSubcharacteristic(aggregateMaint, rankingScores, allMetrics);
    println("OVERALL: " + maintanabilityScore);    
}



