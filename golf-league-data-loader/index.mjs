import {promises as fs} from "fs";
import axios from "axios";
import dotenv from "dotenv";
import XLSX from "xlsx";

async function main() {
    dotenv.config();
    //updateConfigData();
    readSkinsData();
}

async function parseParticipation(participationData) {

}

async function parseScoreData(scoreDataSheetExport) {

}
async function readSkinsData() {
    const workbookpath = process.env.SKINS_WORKBOOK;
    var workbook = XLSX.readFile(workbookpath);
    let participationData = XLSX.utils.sheet_to_json(workbook.Sheets["Skins By Week"]);
    let scoreData = new Array();
    for(var i=1; i<19; i++)
    {
        scoreData.push(XLSX.utils.sheet_to_json(workbook.Sheets["Skins "+i]));
    }
    
}

async function updateConfigData() {
    const localConfigUrl = process.env.CONFIG_SERVICE_URL;

    var data = await loadConfigData();
    var json = JSON.stringify(data);
    const response = await axios.post(localConfigUrl,json);

    console.log(response.statusText);
}

async function loadConfigData() {
    return await fs.readFile('./config_data.json', 'utf8');
}

await main(); 
