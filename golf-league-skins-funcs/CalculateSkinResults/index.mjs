export default async function (context, documents, golfLeagueConfig) {
    let holes = golfLeagueConfig.holes;
    let skinResults = {};
    if (!!documents && documents.length > 0) {
        for(let i = 0; i < documents.length; i++)
        { 
            let scores = documents[i].golferScores;
            let holeidx = 0;
            if(scores.golferScores[0].scores[0] === 0)
                holeidx = 9;
                           
            for(let j = 0; j < scores.length ; j++) {

            }
        }
    }

    return {
        skinResultsDocument : skinResults
    }
}
