// assumes it's a 9 hole round and takes the skinResults data set, 
// looping through each golfer/hole and setting flags if a golfer canceled or won a skin
function calculateSkins(skinResults) {
    for(let i = 0; i < 9; i++) {
        var minScore = getMinScoreForHole(skinResults, i);
        if(minScore.golfersWithScore.length > 1)
        {
            for(let j = 0; j<minScore.golfersWithScore.length; j++){
                skinResults.results[minScore.golfersWithScore[j]][i].cancelSkin = true;
            }
        }
        else{
            skinResults.results[minScore.golfersWithScore[0]][i].isSkin = true;
        }
    }
    skinResults.createDate = Date.now();
    return skinResults;
}

// finds the minimum score for a hole and records which golfers had the score
function getMinScoreForHole(skinResults, holeIndex) {
    let output = {
        minScore: 11,
        golfersWithScore: []
    };
    for(let i in skinResults.results) {
        
        const score = skinResults.results[i][holeIndex].net;
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

function buildSummary(skinResults) {
    let summary = {};
    summary.totalEntrants = 0;
    summary.holes = new Array(9).fill(null).map(() => ({"winner":"none"}) );
    summary.totalSkins = 0;

    for(let golferName in skinResults.results) {
        summary.totalEntrants++;
        let result = skinResults.results[golferName];
        for(let i = 0; i < result.length; i++) {
            if(result[i].isSkin === true) {
                summary.holes[i].winner = golferName;
                summary.holes[i].holeNumber = result[i].holeNumber;
                summary.totalSkins++;
            }
        }
    }
    summary.totalSkinMoney = summary.totalEntrants * 5;
    return summary;
}

// receives vanilla score data for a set of golfers for a given round in a golf league in the 'documents' parameter
// the data is a json document which, in th is case, is sourced out of an Azure Cosmos DB, additionally receives a 
// configuration document in the "golfLeagueConfig" parameter that defines things like the stroke index for a
// given hole
export default async function (context, queueTrigger, golfLeagueConfig, documents) {
    let skinResults = [];
    let skinResultIDs = [];
    
    const scoreData = documents; 
    const golferScores = scoreData.golferScores;
    const strokeIndexes = getStrokeIndexes(golfLeagueConfig[0].courseData.holes,scoreData);
    
    skinResultIDs.push({
        "roundId" : scoreData.id, 
        "roundNumber": scoreData.roundNumber,
        "roundYear" : scoreData.roundYear,
        "roundPlayedDate": scoreData.roundPlayedDate,
        "leagueName" : queueTrigger.leagueName
    });

    skinResults = {};  
    skinResults.id = scoreData.id;
    skinResults.roundYear = scoreData.roundYear;
    skinResults.roundNumber = scoreData.roundNumber;
    skinResults.startHole = scoreData.startHole;
    skinResults.leagueName = queueTrigger.leagueName;
    skinResults.results={};
    
    for(let k = 0; k < golferScores.length; k++) {        
        const golferScore = golferScores[k];
        if(golferScore.inSkins === true)
        {
            const scores = golferScore.scores;            
            skinResults.results[golferScore.golferName] = getHoleResults(golferScore,scores,strokeIndexes,scoreData.startHole);   
        }
    }        
    skinResults = calculateSkins(skinResults);
    skinResults.summary = buildSummary(skinResults);
    
    return {
        skinResultsDocument : skinResults,
        skinResultQueue : skinResultIDs
    }
}
