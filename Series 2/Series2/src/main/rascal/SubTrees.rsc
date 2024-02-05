module SubTrees

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
import util::UUID;
import Node;
import util::Math;


import Normalization;
import Volume;
import Utils;


public map[str, list[node]] hashToNodesMap = ();
data Node = Node(node nodeVal, str hash, int mass, loc src, str id);

// Computes a hash for a node after processing it
public str computeHash(node dataNode) {
    node processedNode = unsetRec(dataNode);
    str computedHash = md5Hash(processedNode);
    if (hashToNodesMap[computedHash]?){
        hashToNodesMap[computedHash] += dataNode;
    }else{
        hashToNodesMap[computedHash] = [dataNode];
    }
    return computedHash;
}

// Generates a unique identifier using UUID
public str generateUniqueId() = uuid().authority;


// Extracts subtrees from a root node based on size and clone detection type
public list[Node] extractSubTrees(node rootNode, int massThreshold) {
    list[Node] extractedSubTrees = [];	

    visit(rootNode) {
        case node currentNode:  {
            if (currentNode.src?) {
                int nodeMass = countNodes(currentNode);
                if (nodeMass >= massThreshold) {
                    node originalNode = currentNode;
                    // if (cloneDetectionType != 1){
                    //     originalNode = normalizeAST(currentNode); 
                    // }				
                    str nodeHash = computeHash(originalNode);
                    Node newNode = Node(originalNode, nodeHash, nodeMass, currentNode.src, generateUniqueId());			 				
                    extractedSubTrees += newNode;
                }
            }
        }
    }
    return extractedSubTrees;
}


// Counts the number of nodes in a given node.
public int countNodes(node dataNode) {
    list[int] nodeCounts = [];
    nodeCounts += for(/node tempNode := dataNode)   
    {
        append(1);
    }
    return size(nodeCounts);
}

// Prepares AST nodes for subtree extraction and clone detection.
public list[node] prepareASTs(list[node] astNodes, int minMass, int cloneType) = 
    ([] | it + extractSubTrees(ast, minMass, cloneType) | ast <- astNodes);


// Identifies clone nodes from a list of candidates.
public map[str, list[Node]] identifyClones(list[Node] cloneCandidates) {
    list[str] hashList = [key | key <- hashToNodesMap];
    hashList = [ h.hash | h <- cloneCandidates];

    set[str] potentialClones = domain(rangeX(distribution(hashList), {1}));

    int totalVolume = 0;
    int totalCloneCount = 0;
    map[str hash, list[Node] nodes] cloneMap = ();
    for (Node candidate <- cloneCandidates, candidate.hash in potentialClones) {
        totalCloneCount += 1;
        if (cloneMap[candidate.hash]?) {
            cloneMap[candidate.hash] += candidate;
            int srcVolume = getVolumePerSource(candidate.src); 
            totalVolume += srcVolume;
        } else {
            int srcVolume = getVolumePerSource(candidate.src);
            totalVolume += srcVolume;
            cloneMap[candidate.hash] = [candidate];
        }   
    }

    int totalVolume2 = 0;
    int maxCloneVolume = 0;
    str largestClone = "";
    str largestCloneClassMembers = "";
    int largestCloneClassSize = 0;
	// exctracting clone classes
    for (str hashKey <- cloneMap){
        if (size(cloneMap[hashKey]) > largestCloneClassSize){
            largestCloneClassSize = size(cloneMap[hashKey]);
            largestCloneClassMembers = readFile(cloneMap[hashKey][0].src);
        }
		// iterating through each clone 
        for (Node element <- cloneMap[hashKey]){
            int elementVolume = getVolumePerSource(element.src);
            totalVolume2 += elementVolume;
            if (elementVolume > maxCloneVolume){
                maxCloneVolume = elementVolume;
                largestClone = readFile(element.src);
            }
        }
    }

	// computing statistics
    // println("Total Volume: " + totalVolume2);
    // println("Total Number of Clone Candidates: " + totalCloneCount);
    // println("Number of Clone Classes: " + size(cloneMap));
    // println("Largest Clone in Lines: " + maxCloneVolume);
    // println("Largest Clone Class in Members: " + largestCloneClassSize);
    // println("Largest Clone Class Members: " + largestCloneClassMembers);
    return cloneMap;
}