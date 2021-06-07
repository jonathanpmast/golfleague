import dotenv from "dotenv"
const path_root = ".env";
if(process.env.NODE_ENVIRONMENT)
    dotenv.config({ path: `${path_root}.${process.env.NODE_ENVIRONMENT}`});
else
    dotenv.config();
const rootUrl = process.env.SERVICE_HOST_URL;

module.exports = {
    configUrl : rootUrl + process.env.LEAGUE_NAME + process.env.CONFIG_SERVICE_PATH,
    scoresUrl : rootUrl + process.env.LEAGUE_NAME + process.env.SCORES_SERVICE_PATH,
    pathsToExcelWorkbook : process.env.SCOREWORKBOOK_PATHS.split("|")
}