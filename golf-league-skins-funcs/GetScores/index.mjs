export default async function (context, req, scoreDoc) {
    context.log('JavaScript HTTP trigger function processed a request.');
    
    return {
        res: {
            body: scoreDoc
        }
    }
}