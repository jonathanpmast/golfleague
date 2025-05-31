#!/usr/bin/env node

/**
 * Cosmos DB Local Emulator Setup Script for Golf League
 * This script automatically creates the required database and collections
 */

const https = require('https');
const crypto = require('crypto');

// Cosmos DB Emulator configuration
const COSMOS_ENDPOINT = 'https://localhost:8081';
const COSMOS_KEY = 'C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==';

// Database and collection configuration
const DATABASE_NAME = 'golfleague';
const COLLECTIONS = [
    'golfleague-config',
    'golfleague-scores',
    'golfleague-skinresults',
    'golfleague-skinsummary'
];
const PARTITION_KEY = '/leagueName';

// Ignore SSL certificate errors for local emulator
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0';

console.log('🚀 Starting Golf League Cosmos DB Setup...');

/**
 * Generate authorization header for Cosmos DB REST API
 */
function getAuthorizationToken(verb, resourceType, resourceId, date, masterKey) {
    const key = Buffer.from(masterKey, 'base64');
    const text = (verb || '').toLowerCase() + '\n' + 
                 (resourceType || '').toLowerCase() + '\n' + 
                 (resourceId || '') + '\n' + 
                 date.toLowerCase() + '\n' + 
                 '' + '\n';
    
    const body = Buffer.from(text, 'utf8');
    const signature = crypto.createHmac('sha256', key).update(body).digest('base64');
    
    return encodeURIComponent(`type=master&ver=1.0&sig=${signature}`);
}

/**
 * Make HTTP request to Cosmos DB
 */
function makeCosmosRequest(method, path, body = null) {
    return new Promise((resolve, reject) => {
        const date = new Date().toUTCString();
        
        // Parse the resource type and ID from the path
        const pathParts = path.split('/').filter(p => p);
        const resourceType = pathParts.length > 0 ? pathParts[0] : '';
        const resourceId = pathParts.length > 1 ? pathParts.slice(1).join('/') : '';
        
        const auth = getAuthorizationToken(method, resourceType, resourceId, date, COSMOS_KEY);
        
        const options = {
            hostname: 'localhost',
            port: 8081,
            path: path,
            method: method,
            headers: {
                'Authorization': auth,
                'x-ms-date': date,
                'x-ms-version': '2018-12-31',
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            rejectUnauthorized: false
        };

        if (body) {
            const bodyString = JSON.stringify(body);
            options.headers['Content-Length'] = Buffer.byteLength(bodyString);
        }

        console.log(`Making ${method} request to ${path}...`);

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                console.log(`Response: ${res.statusCode}`);
                try {
                    const result = {
                        statusCode: res.statusCode,
                        data: data ? JSON.parse(data) : null,
                        headers: res.headers
                    };
                    resolve(result);
                } catch (parseError) {
                    resolve({
                        statusCode: res.statusCode,
                        data: data,
                        headers: res.headers
                    });
                }
            });
        });

        req.on('error', (error) => {
            console.error(`Request error: ${error.message}`);
            reject(new Error(`Request failed: ${error.message}`));
        });

        req.setTimeout(10000, () => {
            req.destroy();
            reject(new Error('Request timeout'));
        });
        
        if (body) {
            req.write(JSON.stringify(body));
        }
        req.end();
    });
}

/**
 * Main setup function
 */
async function setupCosmosDB() {
    try {
        console.log('Testing connection to Cosmos DB Emulator...');
        
        // Test connection
        const testResult = await makeCosmosRequest('GET', '/');
        console.log('Connection test result:', testResult.statusCode);
        
        // Create database
        console.log(`Creating database: ${DATABASE_NAME}...`);
        const dbBody = { id: DATABASE_NAME };
        const dbResult = await makeCosmosRequest('POST', '/dbs', dbBody);
        
        if (dbResult.statusCode === 201) {
            console.log('✅ Database created successfully');
        } else if (dbResult.statusCode === 409) {
            console.log('ℹ️  Database already exists');
        } else {
            console.log(`Database creation status: ${dbResult.statusCode}`);
        }
        
        // Create collections
        for (const collection of COLLECTIONS) {
            console.log(`Creating collection: ${collection}...`);
            const collBody = {
                id: collection,
                partitionKey: {
                    paths: [PARTITION_KEY],
                    kind: 'Hash'
                }
            };
            
            const collResult = await makeCosmosRequest('POST', `/dbs/${DATABASE_NAME}/colls`, collBody);
            
            if (collResult.statusCode === 201) {
                console.log(`✅ Collection '${collection}' created successfully`);
            } else if (collResult.statusCode === 409) {
                console.log(`ℹ️  Collection '${collection}' already exists`);
            } else {
                console.log(`Collection '${collection}' creation status: ${collResult.statusCode}`);
            }
        }
        
        console.log('🎉 Setup completed!');
        console.log('View at: https://localhost:8081/_explorer/index.html');
        
    } catch (error) {
        console.error('❌ Setup failed:', error.message);
        process.exit(1);
    }
}

// Run the setup
setupCosmosDB();
