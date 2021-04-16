export default async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    
    return {
        res: {
            body: null
        }
    }
}