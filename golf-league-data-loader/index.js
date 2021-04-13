import {promises as fs} from "fs";
import axios from "axios";

async function main() {
    const localConfigUrl = "http://localhost:7071/api/Config";

    var data = await loadConfigData();
    var json = JSON.stringify(data);
    const response = await axios.post(localConfigUrl,json);

    console.log(response.statusText);
}

async function loadConfigData() {
    return await fs.readFile('./config_data.json', 'utf8');
}

await main(); 
