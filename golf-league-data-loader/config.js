//import dotenv from "dotenv"
// const path_root = ".env";
// if(process.env.NODE_ENVIRONMENT)
//     dotenv.config({ path: `${path_root}.${process.env.NODE_ENVIRONMENT}`});
// else
//     dotenv.config();
const rootUrl = process.env.SERVICE_HOST_URL;

export const configUrl = rootUrl + process.env.LEAGUE_NAME + process.env.CONFIG_SERVICE_PATH;
export const scoresUrl = rootUrl + process.env.LEAGUE_NAME + process.env.SCORES_SERVICE_PATH;
export const pathsToExcelWorkbook = process.env.SCOREWORKBOOK_PATHS.split("|");
export const startYear = process.env.START_YEAR || 2020;