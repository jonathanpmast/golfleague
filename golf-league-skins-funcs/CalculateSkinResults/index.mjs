// assumes it's a 9 hole round and takes the skinResults data set, 
// looping through each golfer/hole and setting flags if a golfer canceled or won a skin
function calculateSkins(skinResults) {
    for(let i = 0; i < 9; i++) {
        var minScore = getMinScoreForHole(skinResults, i);
        if(minScore.golfersWithScore.length > 1)
        {
            for(let j = 0; j<minScore.golfersWithScore.length; j++){
                skinResults.results[minScore.golfersWithScore[j]][i].cancelSkin=true;
            }
        }
        else{
            skinResults.results[minScore.golfersWithScore[0]][i].isSkin = true;
        }
    }

    return skinResults;
}

// finds the minimum score for a hole and records which golfers had the score
function getMinScoreForHole(skinResults, holeIndex) {
    let output = {
        minScore: 11,
        golfersWithScore: []
    };
    for(let i in skinResults.results) {
        
        const score = skinResults.results [i][holeIndex].net;
        if(score === output.minScore)
            output.golfersWithScore.push(i);
        if(score < output.minScore) {
            output.golfersWithScore.length=0;
            output.golfersWithScore.push(i);
            output.minScore = score;
        }
        
    } 
    return output;
}

// pulls data out of the vanilla score results and adds them to a data object
// that supports additional metadata for calculating, recording, and displaying
// skin results
function getHoleResults(golferScore, scores, strokeIndexes, startHole) {
    let holeResults = [];
    for(let scoreIdx = 0; scoreIdx< scores.length; scoreIdx++)
    {
        holeResults[scoreIdx] = {
            gross: scores[scoreIdx],
            net: strokeIndexes[scoreIdx] <= golferScore.handicap ? scores[scoreIdx] - 1 : scores[scoreIdx],
            isSkin: false,
            cancelSkin: false,
            holeNumber: scoreIdx+startHole
        };
    }
    return holeResults;
}
// fills up and returns an array with each stroke index 
// for the holes being played in the round
function getStrokeIndexes(holes,scoreData) {
    let strokeIndexes = [];
    for(let j = 0; j < 9; j++) {
        strokeIndexes[j] = Math.round(holes[j+scoreData.startHole-1].strokeIndex/2);
    }
    return strokeIndexes;
}

// receives vanilla score data for a set of golfers for a given round in a random golf league in the 'documents' parameter
// the data is a json document which, in th is case, is sourced out of an Azure Cosmos DB, additionally receives a 
// configuration document in the "golfLeagueConfig" parameter that defines things like the stroke index for a
// given hole
export default async function (context, documents, golfLeagueConfig) {
    let skinResults = [];
    if (!!documents && documents.length > 0) {
        for(let i = 0; i < documents.length; i++)
        { 
            const scoreData = documents[i];
            const golferScores = scoreData.golferScores;
            const strokeIndexes = getStrokeIndexes(golfLeagueConfig.courseData.holes,scoreData);
            skinResults[i] = {};  
            skinResults[i].id = scoreData.id;
            skinResults[i].roundYear = scoreData.roundYear;
            skinResults[i].startHole = scoreData.startHole;
            skinResults[i].results={};
            for(let k = 0; k < golferScores.length; k++) {
                const golferScore = golferScores[k];
                const scores = golferScore.scores;
                
                skinResults[i].results[golferScore.golferName] = getHoleResults(golferScore,scores,strokeIndexes,scoreData.startHole);   
            }        
            skinResults[i] = calculateSkins(skinResults[i]);
        }
    }
    return {
        skinResultsDocument : skinResults
    }
}
