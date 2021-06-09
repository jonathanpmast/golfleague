import {promises as fs} from "fs";
import axios from "axios";
import XLSX from "xlsx";
import {pathsToExcelWorkbook,scoresUrl,configUrl} from "./config.js";

async function main() {
    console.log("starting...");
    
    await updateConfigData(configUrl);
    for(let i=0; i < pathsToExcelWorkbook.length; i++)
    {
        let pathToExcelWorkbook = pathsToExcelWorkbook[i];
        console.log("Processing " + pathToExcelWorkbook);
        let skinsData = await readSkinsData(pathToExcelWorkbook,2020 + i, i == 0);
        for(let idx = 0; idx < skinsData.roundData.length; idx++) {
            let roundData = skinsData.roundData[idx];
            
            let json = JSON.stringify(roundData);
            console.log(`Posting scores for Round: ${roundData.roundId}`)
            const response = await axios.post(scoresUrl, json);
            console.log(response.statusText);
        }
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

async function parseScoreData(sourceScoreData, roundYear,roundNum,skinsOnly) {
    const handicapColumnIndex = skinsOnly ? 2 : 3;
    const inSkinsColumnIndex = skinsOnly ? 1 : 2;
    const scoreColumnOffset = skinsOnly ? 3 : 4;
    let roundPlayedDate = new Date(new Date(1900,0,1).setDate(sourceScoreData[2][0]-1));
    
    let scoreData = {
        "roundId": `${roundYear}${roundNum}`,
        "golferScores":[],
        "startHole": null,
        "roundPlayedDate": roundPlayedDate
    };
    console.log(scoreData.roundPlayedDate);
    let golferCount=0;
    for(let i=0;i<sourceScoreData.length;i++) {
        let row = sourceScoreData[i];
        //if they played the round, record their score
        if(row[1] !== null && row[1] === "X")
        {
            if(golferCount === 0)
                scoreData.startHole = row[scoreColumnOffset] > 0 ? 1 : 10;
            let inSkins = (skinsOnly ? true : row[inSkinsColumnIndex] === 'X');
            console.log(inSkins);
            scoreData.golferScores[golferCount] = {
                "golferName" : row[0],
                "handicap": row[handicapColumnIndex],
                "scores" :[],
                "inSkins": inSkins
            };
            
            for(let holeNum = 0; holeNum < 9; holeNum++) 
            {
                
                if(row[holeNum + (scoreData.startHole - 1) + scoreColumnOffset] !== null)
                    scoreData.golferScores[golferCount].scores[holeNum] = row[holeNum+ (scoreData.startHole - 1)+scoreColumnOffset];
            }
            golferCount += 1;
        }
    }
    return scoreData;
}

async function readSkinsData(workbookpath,roundYear,skinsOnly) {
    
    var workbook = XLSX.readFile(workbookpath);
    let skinsData = {};    
    skinsData.participationData = await parseParticipation(XLSX.utils.sheet_to_json(workbook.Sheets["Skins By Week"],{header:1}));
    skinsData.roundData=[];
    for(var i=1; i < 19; i++)
    {
        if(workbook.Sheets["Skins " +i] !== undefined) {
            let scores = await parseScoreData(XLSX.utils.sheet_to_json(workbook.Sheets["Skins "+i],{header:1}),roundYear,i,skinsOnly);
            skinsData.roundData.push(scores);
        }
    }
    
    return skinsData;
}

async function updateConfigData(configUrl) {

    var data = JSON.parse(await loadConfigData());
    var json = JSON.stringify(data);
    
    const response = await axios.post(configUrl,json);

    console.log(response.statusText);
}


async function loadConfigData() {
    return await fs.readFile('./config_data.json', 'utf8');
}

await main(); 
