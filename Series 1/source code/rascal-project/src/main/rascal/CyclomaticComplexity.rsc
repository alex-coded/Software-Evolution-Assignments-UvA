
module CyclomaticComplexity

import Utilitary;
import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;


int getCyclomaticComplexityOfFunction(Statement implementation){
    int CC = 1; 
        visit (implementation) { 
            case \if(_, _): CC += 1; 
            case \if(_, _, _): CC += 1; 
            case \for(_, _, _, _): CC += 1; 
            case \for (_, _, _): CC += 1; 
            case \foreach(_, _, _): CC += 1; 
            case \while(_, _): CC += 1; 
            case \do(_, _): CC += 1;
            case \case(_): CC += 1;  
            case \defaultCase(): CC += 1;
            case \catch(_, _): CC += 1;
            case \infix(_, _, _): CC += 1;
        }
        return CC;
}

tuple[str, int] getFunctionCathegoryAndVolume(Statement implementation){
    int CC = 0;
    CC = getCyclomaticComplexityOfFunction(implementation);
    str complexity = "very high";    
    int volume = getNrOfCodeLinesPerSource(implementation.src);
    if (CC <= 10){
        complexity = "low";
    } else if (CC <= 20) {
        complexity = "moderate";

    } else if (CC <= 50) {
        complexity = "high";
    }
    return <complexity, volume>;
}




map[str, int] getRiskToVolumeMap(list[Declaration] asts){
    map[str, int] riskToVolume = ();
    for(ast <- asts){ 
        visit (ast) {
            case \method(_, _, _, _, impl):{
                tuple[str, int] tupleFunc = getFunctionCathegoryAndVolume(impl);
                riskToVolume[tupleFunc[0]] ? 0 += tupleFunc[1];               
            }
            case \constructor(_, _, _, impl):{
                tuple[str, int] tupleFunc = getFunctionCathegoryAndVolume(impl);
                riskToVolume[tupleFunc[0]] ? 0 += tupleFunc[1];                 
            }
            case \initializer(impl):{
            tuple[str, int] tupleFunc = getFunctionCathegoryAndVolume(impl);
            riskToVolume[tupleFunc[0]] ? 0 += tupleFunc[1];              
            }
        }
    }
    return riskToVolume;
}


str calculateUnitComplexity(list[Declaration] asts, int volume){
    println("Unit Comlexity: UCC");
    map[str, int] riskToVolume = getRiskToVolumeMap(asts);
    map[str, real] footPrintPercentage = getRiskFootPrintPercentage(riskToVolume, volume);
    for (str element <- ["low", "moderate", "high", "very high"]){
        println("• Num of " + element + ": (<round(footPrintPercentage[element])>%)<(riskToVolume[element])>");
    }
    str systemComplexity = getSystemComplexityRatingBasedOnCC(footPrintPercentage);
    return systemComplexity; 
}