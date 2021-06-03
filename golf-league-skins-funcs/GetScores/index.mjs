export default async function (context, req, scoreDocs) {
    context.log('JavaScript HTTP trigger function processed a request.');
    
    return {
        res: {
            body: scoreDocs
        }
    }
}