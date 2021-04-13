export default async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    context.log('Method: ' + req.method);
    let configData = null;
    let response = {};
    if(req.method === 'POST')
    {   
        configData = JSON.parse(req.body);

        response.outputDocument = configData;
        response.res = {
            body: 'Success'
        };
    }
    if(req.method === 'GET')
    {
        response.res = {
            body: 'You sent a Get request :|'
        }
    }
    
    return response;
}