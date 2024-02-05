module UnitTestCoverage


import Utilitary;
import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;


list[str] javaAssertStatements = [
    "assert", "assertEquals", "assertTrue", "assertNull", 
    "assertFalse", "assertNotNull", "assertSame", "assertNotSame", 
    "assertArrayEquals", "assertThrows", "assertNotEquals", 
    "assertIterableEquals", "assertLinesMatch", "assertTimeout", 
    "assertTimeoutPreemptively", "assertAll", "assertEqualsNoOrder", 
    "assertNotEqualsDeep", "fail", "assertThat"
];

real unitTesting(list[Declaration] asts, int volume){
    println("Test Coverage: no of assert calls");
    int assertStatements = 0;
    for(ast <- asts){   
        visit (ast) {
            case \methodCall(_, name, _):{
                if (name in javaAssertStatements) {
                    assertStatements += 1;
                }
            }
        }
    }
    real assertRatio = toReal(assertStatements)/toReal(volume);
    println("• LOC: <volume>");
    println("• Assert Statements: <assertStatements>");
    println("• Assert Ratio: <assertRatio>");
    return assertRatio;
}