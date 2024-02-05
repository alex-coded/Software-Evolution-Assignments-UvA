module Main
import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import DateTime;
import Normalization;
import Sequences;
import SubTrees;
import Volume;
import Utils;

loc path = |project://series2/TestProjects/smallsql0.21_src|;
// loc path = |project://rascal-project0/TestProjects/hsqldb-2.3.1/hsqldb-2.3.1|;
// loc path = |home:///hsqldb-2.3.1/hsqldb-2.3.1|;


// here the main function is computed
int main(){
	datetime beginTime = now();
    println("Starting the sequencing algorithm");
    list [Declaration] declarations = getASTsList(path); 

    // calling the sequencing function, which will compute the clone detection algorithm
	sequencing(declarations, Type1(), path);

    // computing the time for algorithm + stats computation
	datetime endTime = now();
    interval totalTime = createInterval(beginTime, endTime);
    print("• Total run duration: \<y, mo, days, h, min, sec, milisec\>: ");
    println("<createDuration(totalTime)>\n");
    return 0;
}


