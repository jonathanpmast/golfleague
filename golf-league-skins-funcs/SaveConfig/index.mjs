export default async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    context.log('Method: ' + req.method);
    let configData = req.body;
    configData.createDate = Date.now();
    configData.leagueName = context.bindingData.league;
    
    return {
        outputDocument : configData,
        res: {
            body: "Success"
        }
    }    
}