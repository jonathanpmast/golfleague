import {promises as fs} from "fs";
import axios from "axios";
import dotenv from "dotenv";

async function main() {
    dotenv.config();
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
