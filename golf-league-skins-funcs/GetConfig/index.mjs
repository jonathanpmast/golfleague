export default async function (context, req, configData) {
    context.log('JavaScript HTTP trigger function processed a request.');
    
    
    return {
        res : 
        {
            body: {
                    id: configData.id,
                    courseData: configData.courseData
            }
        }
    }
}