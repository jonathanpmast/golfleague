export default async function (context, req, skinResultsDocuments) {
    
    return {
        res: {
            body: skinResultsDocuments
        }
    }
}