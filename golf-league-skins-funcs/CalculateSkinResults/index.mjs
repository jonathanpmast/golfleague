function calculateSkins(skinResults) {
    for(let i = 0; i < 9; i++) {
        var minScore = getMinScoreForHole(skinResults, i);
        if(minScore.golfersWithScore.length > 1)
        {
            for(let j = 0; j<minScore.golfersWithScore.length; j++){
                skinResults[minScore.golfersWithScore[j]][i].cancelSkin=true;
            }
        }
        else{
            skinResults[minScore.golfersWithScore[0]][i].isSkin = true;
        }
    }

    return skinResults;
}

function getMinScoreForHole(skinResults, holeIndex) {
    let output = {
        minScore: 11,
        golfersWithScore: []
    };
    for(let i in skinResults) {
        if(i !== "id" && i !== "roundYear") { 
            const score = skinResults[i][holeIndex].net;
            if(score === output.minScore)
                output.golfersWithScore.push(i);
            if(score < output.minScore) {
                output.golfersWithScore.length=0;
                output.golfersWithScore.push(i);
                output.minScore = score;
            }
        }
    }
    return output;
}

function getHoleResults(golferScore, scores, strokeIndexes) {
    let holeResults = [];
    for(let scoreIdx = 0; scoreIdx< scores.length; scoreIdx++)
    {
        holeResults[scoreIdx] = {
            gross: scores[scoreIdx],
            net: strokeIndexes[scoreIdx] <= golferScore.handicap ? scores[scoreIdx] - 1 : scores[scoreIdx],
            isSkin: false,
            cancelSkin: false,
            holeNumber: scoreIdx+1
        };
    }
    return holeResults;
}

function getStrokeIndexes(holes,scoreData) {
    let strokeIndexes = [];
    for(let j = 0; j < 9; j++) {
        strokeIndexes[j] = Math.round(holes[j+scoreData.startHole-1].strokeIndex/2);
    }
    return strokeIndexes;
}

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
            // { gross: int, net: int, isSkin:bool, cancelSkin:bool }
            for(let k = 0; k < golferScores.length; k++) {
                const golferScore = golferScores[k];
                const scores = golferScore.scores;
                
                skinResults[i][golferScore.golferName] = getHoleResults(golferScore,scores,strokeIndexes);   
            }        
            skinResults[i] = calculateSkins(skinResults[i]);
        }
    }
    return {
        skinResultsDocument : skinResults
    }
}
