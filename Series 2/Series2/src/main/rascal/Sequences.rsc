module Sequences

import lang::java::m3::Core; 
import lang::java::m3::AST; 
import IO;
import List;
import Set;
import String;
import Map;
import util::Math;
import Type;
import DateTime;

import Node;
import util::Math;


import Normalization;
import Volume;
import Utils;

int minimumSequenceLength = 3;

data AlgoCloneType = Type1() | Type2();

set[str] configUnsetTypeI = {"src", "decl"};
set[str] configUnsetTypeII = {"src", "decl", "typ"};

// cleaning the node for type1
node cleanStatementListTypeI(node n) {
    return unsetRec(n, configUnsetTypeI);
}

// cleaning the node for type2
node cleanStatementListTypeII(node n) {
    return unsetRec(n, configUnsetTypeII);
}

loc outFile = |project://series2/src/main/rascal/exportFiles/Out.txt|;
loc csvExportFile = |project://series2/src/main/rascal/exportFiles/Export.csv|;


// Checks and normalizes declarations based on the algorithm type.
list[Declaration] checkForNormalization(list[Declaration] declarations, AlgoCloneType algType){
    if (algType == Type2()){
        return normalizeASTNodes(declarations);
    }
    return declarations;
}

// Updates a hash map with sequences and their corresponding hashes.
 map[str, list[list[node]]] updateSequenceHashMap( map[str, list[list[node]]] sequenceHashMap, list[node] currentSequence, str sequenceHash){
    if (sequenceHash in sequenceHashMap){
        sequenceHashMap[sequenceHash] += [currentSequence];
    } else{
        sequenceHashMap[sequenceHash] = [currentSequence];
    }
    return sequenceHashMap;
 }


// sequencing function, which is responsible for finding the clones 
// the algorithm heavily relies on Baxter's paper
void sequencing(list[Declaration] astNodes, AlgoCloneType algType, loc path){

    // Initialize hash maps for storing sequences and detected clones
    map[str, list[list[node]]] sequenceHashMap = ();
    map[str k, list[node] values] clones = ();
    map[str, list[list[node]]] detectedClones = (); 

    astNodes = checkForNormalization(astNodes, algType);
    list[node] unsetRecStatements = [];

    // Start a bottom-up visit of the AST nodes
    bottom-up visit(astNodes){
        case list[Statement] \statementList: {
            // Choose the cleaning method based on the algorithm type
            if (algType != Type1()) { 
                unsetRecStatements = mapper(statementList, cleanStatementListTypeII);  
            }
            else { 
                unsetRecStatements = mapper(statementList, cleanStatementListTypeI); 
            }
            int statementCount = size(statementList);
            
            // Process only if statement count meets minimum sequence length
            if (statementCount >= minimumSequenceLength){
                for (sequenceLength <- [minimumSequenceLength..statementCount+1]){
                    int bound = statementCount-sequenceLength+1;
                    for (startIndex <- [0..bound]){
                        int endIndex = startIndex + sequenceLength;

                        // Extract a sequence of statements and compute its hash
                        list[node] unsetSequence = unsetRecStatements[startIndex..endIndex];
                        str sequenceHash = md5Hash(unsetSequence);
                        list[node] currentSequence = statementList[startIndex..endIndex];

                        // Update /add the current sequence in the sequence hash map
                        sequenceHashMap = updateSequenceHashMap(sequenceHashMap, currentSequence, sequenceHash);

                        // Check if the sequence is a clone (appears more than once)
                        int seqHashMapSize = size(sequenceHashMap[sequenceHash]);
                        if (seqHashMapSize >= 2){
                            detectedClones[sequenceHash] = sequenceHashMap[sequenceHash];						
                            for (subSeqLength <- [minimumSequenceLength..sequenceLength]){
                                int subSequenceLimit = size(currentSequence)-subSeqLength+1;
                                for (subSeqStart <- [0..subSequenceLimit]){
                                    int upperBound = subSeqStart+subSeqLength;
                                    // Extract and check subsequences for clones
                                    list[node] subSequence = unsetSequence[subSeqStart..upperBound];
                                    // Remove subsequence clones                                 
                                    if (unsetSequence != subSequence){
                                        str subSequenceHash = md5Hash(subSequence);
                                        if (subSequence != unsetSequence){
                                            if(subSequenceHash in detectedClones){
                                                detectedClones = delete(detectedClones, subSequenceHash); 
                                            }   
                                        }
                                    }
                                }
                            }
                            // subsumption step
                            clones = remove(currentSequence, clones);
                        }
                    }
                }
            }
        }
    }
    computingStats(detectedClones, path);
}

// Subsumption - removing sequences from the clones map based on their hash
map[str k, list[node] values] remove(list[node] currentSequence, map[str k, list[node] values] clones){
    for (subTree <- currentSequence)
        if (md5Hash(subTree) in clones) { 
            clones = delete(clones, md5Hash(subTree)); 
        }
    return clones;
}
 
// computing statistics for the detected clones
void computingStats(map[str, list[list[node]]] detectedClones, loc path){
    println("Finished algorithm. Computing stats.");
	loc location = outFile;
	writeFile(location, "TEXTUAL REPRESENTATION\n\n");
    appendToFile(location, "Please take note that \\n\\t content was escaped for representation of clones for space efficiency"); 

    // intialize variables for tracking clone statistics
	int totalVolume = 0;
	int totalNumberOfClones = 0;
    int cloneGroupCounter = 0;
    int biggestClone = 0;
    int cloneClassMembers = 0;
    int maxCloneClassMembers = 0;
    str maxCloneClassMembersStr = "";
    int cloneClassLines = 0;
    str biggestCloneInLinesStr = "";
    int maxCloneInLines = 0;
    map[str, int] exportMapLocationLOC = ();
    map[str, str] sequencePairLocations = ();

    // Iterating through each class
	for (seqHash <- detectedClones) {
		appendToFile(location, "\n\n---------------------------Clone group no  " + toString(cloneGroupCounter) + " for hash " + seqHash +  "--------------------\n\n");
        cloneClassMembers = 0;
        cloneClassLines = 0;
        // Iterating through each clone
		for (list[node] cloneSeq <- detectedClones[seqHash]) {
			appendToFile(location , "\n\n");
            cloneClassMembers += 1;
            totalNumberOfClones += 1;
            // appendToFile(location, "\nClone found at "+ extractLocationFromNode[cloneSeq[0]].path + " at line " + "cloneSeq[0].begin.line\n");
            // Iterating through each sequence of the clone and writing it
			for (node n <- cloneSeq){ 
                loc l = extractLocationFromNode(n);
                int vol = getVolumePerSource(l);
				totalVolume += vol;
                cloneClassLines += vol;
                // export file contents
				appendToFile(location,  formatContentFromClone(l)); 
                if (l.path in exportMapLocationLOC){
                    exportMapLocationLOC[l.path] += vol;
                } else{
                    exportMapLocationLOC[l.path] = vol;
                }
			}	
            // checking for the class with maximum clone members
            if (cloneClassMembers > maxCloneClassMembers){
                maxCloneClassMembersStr = "Class " + toString(cloneGroupCounter);
                maxCloneClassMembers = cloneClassMembers;
            }
            // checking for class with maximum clone lines
            if (cloneClassLines > maxCloneInLines){
                biggestCloneInLinesStr = "Class " + toString(cloneGroupCounter) + " having " + toString(cloneClassLines) + " lines";
                maxCloneInLines = cloneClassLines;
            }
		}
        cloneGroupCounter += 1;
	}

    for (seqHash <- detectedClones) {
        // Iterating through each clone
		for (list[node] cloneSeq <- detectedClones[seqHash]) {
            for (list[node] cloneSeq2 <- detectedClones[seqHash]){
                loc l1 = extractLocationFromNode(cloneSeq[0]);
                loc l2 = extractLocationFromNode(cloneSeq2[0]);
               
                if (l1.path in sequencePairLocations){
                sequencePairLocations[l1.path] += l2.path;
                } else{
                sequencePairLocations[l1.path] = l2.path;
                }                 
            } 
        }
    }

    writeFile(|project://series2/src/main/rascal/exportFiles/Export2.csv|, "Loc1,Loc2");
    for (elm <- sequencePairLocations){
        appendToFile(|project://series2/src/main/rascal/exportFiles/Export2.csv|,"\n<elm>,"+"<sequencePairLocations[elm]>\n");
    }

    int systemVolume = volume(path);
    // print the statistics
    println("• Total volume of the system: <systemVolume> LOC");
    println("• Volume of duplicated lines: (<totalVolume*100/systemVolume>%)<totalVolume>" + " LOC");
    println("• Number of clones: <totalNumberOfClones>");
    println("• Number of clone classes: <size(detectedClones)>");
	println("• Biggest clone class (in members): <maxCloneClassMembersStr> with <maxCloneClassMembers> members");
    println("• Biggest clone (in lines): <biggestCloneInLinesStr>");

    writeFile(csvExportFile, "Location, LOC");
    for (elm <- exportMapLocationLOC){
        appendToFile(csvExportFile,"\n<elm>,"+"<exportMapLocationLOC[elm]>");
    }
}
