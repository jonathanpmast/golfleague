export default async function (context, req, configData) {
    context.log('JavaScript HTTP trigger function processed a request.');
    
    
    return {
        res : 
        {
            body: {
                    id: configData[0].id,
                    courseData: configData[0].courseData
            }
        }
    }
}