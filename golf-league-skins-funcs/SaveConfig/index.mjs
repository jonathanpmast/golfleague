export default async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    context.log('Method: ' + req.method);
    let configData = null;
    let response = {};
    configData = JSON.parse(req.body);
    configData.createDate = Date.now();
    response.outputDocument = configData;
    response.res = {
        body: 'Success'
    };
        
    return response;
}