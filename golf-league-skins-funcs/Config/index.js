module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    //const name = (req.query.name || (req.body && req.body.name));
    // const responseMessage = name
    //     ? "Hello, " + name + ". This HTTP triggered function executed successfully."
    //     : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";

    // if (name) {
    //     context.bindings.outputDocument = JSON.stringify({
    //         id: new Date().toISOString() + Math.random().toString().substr(2,8),
    //         name: name
    //     });
    // }
    const configData = JSON.parse(req.body);
    // context.bindings.outputDocument=configData;


    // context.res = {
    //     // status: 200, /* Defaults to 200 */
    //     body: "Success"
    // };

    return {
        res: {
            body: "Success"
        },
        outputDocument: configData
    }
}