export default async function (context, req, skinResultsDocument) {
    context.log(skinResultsDocument);
    return {
        res: {
            body: skinResultsDocument
        }
    }
}