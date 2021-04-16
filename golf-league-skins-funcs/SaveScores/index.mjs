export default async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    let scoreToSave = req.body;
    scoreToSave.roundYear =  scoreToSave.roundId.toString().substring(0,4);
    scoreToSave.id = scoreToSave.roundId;
    context.log(scoreToSave);
    return {
        res: {body: "Success" },
        score: scoreToSave
    }
}