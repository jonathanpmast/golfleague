import {promises as fs} from "fs";
import axios from "axios";
import dotenv from "dotenv";
import XLSX from "xlsx";

async function main() {
    console.log("starting...");
    dotenv.config();

    const configUrl = process.env.CONFIG_SERVICE_URL;
    const pathToExcelWorkbook = process.env.SKINS_WORKBOOK;
    const scoresUrl = process.env.SCORES_SERVICE_URL;
    
    await updateConfigData(configUrl);
    let skinsData = await readSkinsData(pathToExcelWorkbook);
    for(let idx = 0; idx < skinsData.roundData.length; idx++) {
        let roundData = skinsData.roundData[idx];
        
        let json = JSON.stringify(roundData);
        console.log(json);
        const response = await axios.post(scoresUrl, json);
        console.log(response.statusText);
    }
}

async function parseParticipation(sourceParticipationData) {
    var participationData = [];
    let startParsingAt = 2;
    let rowNum= startParsingAt;
    for(rowNum;rowNum<sourceParticipationData.length;rowNum++) {
        let row = sourceParticipationData[rowNum];
        
        participationData[rowNum-startParsingAt] = {
            "golferName": row[0],
            "participationByRound": new Array(18)
        };
        for(let roundNum=0;roundNum < 18; roundNum++)
        {
            participationData[rowNum-startParsingAt].participationByRound[roundNum] = row[roundNum+1] != null ? true : false;
        }
    }
    return participationData;
}

async function parseScoreData(sourceScoreData, roundYear,roundNum) {
    let scoreColumnOffset = 3
    let scoreData = {
        "roundId": `${roundYear}${roundNum}`,
        "golferScores":[]
    }
    let golferCount=0;
    for(let i=0;i<sourceScoreData.length;i++) {
        let row = sourceScoreData[i];
        if(row[1] !== null && row[1] === "X")
        {
            scoreData.golferScores[golferCount] = {
                "golferName" : row[0],
                "handicap": row[2],
                "scores" :[]
            };
            for(let holeNum = 0; holeNum < 18; holeNum++) 
            {
                scoreData.golferScores[golferCount].scores[holeNum] = row[holeNum+scoreColumnOffset] ?? 0;
            }
            golferCount += 1;
        }
    }
    return scoreData;
}

async function readSkinsData(workbookpath) {
    
    var workbook = XLSX.readFile(workbookpath);
    let skinsData = {};    
    skinsData.participationData = await parseParticipation(XLSX.utils.sheet_to_json(workbook.Sheets["Skins By Week"],{header:1}));
    skinsData.roundData=[];
    for(var i=1; i<19; i++)
    {
        let scores = await parseScoreData(XLSX.utils.sheet_to_json(workbook.Sheets["Skins "+i],{header:1}),2020,i);
        
        skinsData.roundData.push(scores);
    }
    console.log(skinsData);
    return skinsData;
}

async function updateConfigData(configUrl) {

    var data = await loadConfigData();
    var json = JSON.stringify(data);
    const response = await axios.post(configUrl,json);

    console.log(response.statusText);
}

async function updateSkinsData(skinsData) {
    
}

async function loadConfigData() {
    return await fs.readFile('./config_data.json', 'utf8');
}

await main(); 
