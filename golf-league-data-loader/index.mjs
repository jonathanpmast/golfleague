import {promises as fs} from "fs";
import axios from "axios";
import dotenv from "dotenv";
import XLSX from "xlsx";

async function main() {
    console.log("starting...");
    dotenv.config();
    updateConfigData();
    let skinsData = readSkinsData();
}

async function parseParticipation(sourceParticipationData) {
    let participationData = [];
    let startParsingAt = 2;
    let rowNum= startParsingAt;
    for(rowNum;rowNum<sourceParticipationData.length;rowNum++) {
        let row = sourceParticipationData[rowNum];
        
        participationData[rowNum-startParsingAt] = {
            "GolferName": row["__EMPTY"],
            "ParticipationByRound": new Array(18)
        };
        for(let roundNum=0;roundNum < 18; roundNum++)
        {
            participationData[rowNum-startParsingAt].ParticipationByRound[roundNum] = row[roundNum+1] != null ? true : false;
        }
    }
    return participationData;
}

async function parseScoreData(sourceScoreData, roundNum) {
    let scoreColumnOffset = 3
    let scoreData = {
        "RoundNumber": roundNum,
        "GolferScores":[]
    }
    let golferCount=0;
    for(let i=0;i<sourceScoreData.length;i++) {
        let row = sourceScoreData[i];
        if(row[1] !== null && row[1] === "X")
        {
            scoreData.GolferScores[golferCount] = {
                "GolferName" : row[0],
                "Handicap": row[2],
                "Scores" :[]
            };
            for(let holeNum = 0; holeNum < 18; holeNum++) 
            {
                scoreData.GolferScores[golferCount].Scores[holeNum] = row[holeNum+scoreColumnOffset] ?? 0;
            }
            golferCount += 1;
        }
        //if(row[0] !== null || row[0] !== "Golfer" || row[0] !== "Net")
    }
    return scoreData;
}

async function readSkinsData() {
    const workbookpath = process.env.SKINS_WORKBOOK;
    var workbook = XLSX.readFile(workbookpath);
    let skinsData = {};    
    skinsData["ParticipationData"] = await parseParticipation(XLSX.utils.sheet_to_json(workbook.Sheets["Skins By Week"]));
    skinsData.RoundData=[];
    for(var i=1; i<19; i++)
    {
        let scores = await parseScoreData(XLSX.utils.sheet_to_json(workbook.Sheets["Skins "+i],{header:1}),i);
        
        skinsData.RoundData.push(scores);
    }
    return skinsData;
}

async function updateConfigData() {
    const localConfigUrl = process.env.CONFIG_SERVICE_URL;

    var data = await loadConfigData();
    var json = JSON.stringify(data);
    const response = await axios.post(localConfigUrl,json);

    console.log(response.statusText);
}

async function updateSkinsData(skinsData) {
    
}

async function loadConfigData() {
    return await fs.readFile('./config_data.json', 'utf8');
}

await main(); 
