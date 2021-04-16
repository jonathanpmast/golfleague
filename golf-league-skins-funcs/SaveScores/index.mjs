export default async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    let scoreToSave = req.body;
    console.log(scoreToSave);
    return {
        res: {body: "Success" },
        score: scoreToSave
    }
}