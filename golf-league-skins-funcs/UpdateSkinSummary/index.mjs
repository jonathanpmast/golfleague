export default async function (context, queueItem, skinSummaryDoc, skinResultDoc) {
    context.log(queueItem,skinSummaryDoc,skinResultDoc); 
    let outSkinSummary = skinSummaryDoc;
    if(typeof(skinSummaryDoc) == 'undefined' || skinSummaryDoc == null) {
        outSkinSummary = {
            "updateDate" : Date.now(),
            "players" : {},
            "totalSkins" : 0,
            "totalMoney" : 0,
            "leaguename" : process.env.LeagueName,
            "roundYear" : skinResultDoc.roundYear,
            "processedRounds" : {}
        };
    }
    if( outSkinSummary.processedRounds[skinResultDoc.id] && 
        outSkinSummary.processedRounds[skinResultDoc.id] < skinResultDoc.createDate) {
            outSkinSummary = processRound(outSkinSummary, skinResultDoc);
    }

    outSkinSummary.processedRounds[skinResultDoc.id] = skinResultDoc.createDate;
    return {
        outSkinSummaryDoc : outSkinSummary
    }
}

function processRound(outSkinSummary, skinResultDoc) {
    
    return outSkinSummary;
}