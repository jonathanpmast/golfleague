export default async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    let scoreToSave = req.body;
    scoreToSave.roundYear =  scoreToSave.roundId.toString().substring(0,4);
    scoreToSave.roundNumber = scoreToSave.roundId.toString().substring(4);
    scoreToSave.id = scoreToSave.roundId;
    scoreToSave.createDate = Date.now();
    scoreToSave.leagueName = context.bindingData.league;
    let queueItem = {
        leagueName: context.bindingData.league,
        roundYear : scoreToSave.roundYear,
        roundId : scoreToSave.roundId
    };
    return {
        res: {body: "Success" },
        score: scoreToSave,
        outputQueueItem: queueItem
    }
}