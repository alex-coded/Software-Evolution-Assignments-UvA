module UnitSize


import Utilitary;
import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;


str getUnitCategory(int volume){
    str complexity = "very high";
    if (volume <= 15){
        complexity = "low";
    } else if (volume <= 30) {
        complexity = "moderate";
    } else if (volume <= 60) {
        complexity = "high";
    }
    return complexity;
}


map[str, real] getUnitSize(list[Declaration] asts, int volume){
    println("Unit Size: ULOC");
    map[str category, int counts] mapUnitsCategory = ();
    for(ast <- asts){ 
        visit (ast) {
            case \method(_, _, _, _, impl):{
                int methodVolume = getNrOfCodeLinesPerSource(impl.src);
                str category = getUnitCategory(methodVolume);
                mapUnitsCategory[category] ? 0 += methodVolume;
            }
            case \constructor(_, _, _, impl):{
                int methodVolume = getNrOfCodeLinesPerSource(impl.src);
                str category = getUnitCategory(methodVolume);
                mapUnitsCategory[category] ? 0 += methodVolume;
            }
            case \initializer(impl):{
                int methodVolume = getNrOfCodeLinesPerSource(impl.src);
                str category = getUnitCategory(methodVolume);
                mapUnitsCategory[category] ? 0 += methodVolume;
            }
        }
    }
    map[str, real] complexityRiskFootPrint = getRiskFootPrintPercentage(mapUnitsCategory, volume);
     for (str element <- ["low", "moderate", "high", "very high"]){
        println("• Num of " + element + ": (<round(complexityRiskFootPrint[element])>%)<(mapUnitsCategory[element])>");
    }
    return complexityRiskFootPrint;
}


