#!/usr/bin/env node

/**
 * Cosmos DB Emulator Setup Script
 * This script creates the required database and collections for the Golf League application
 */

const https = require('https');
const crypto = require('crypto');

// Cosmos DB Emulator configuration
const COSMOS_ENDPOINT = 'https://127.0.0.1:8081';
const COSMOS_KEY = 'C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==';
const DATABASE_NAME = 'golfleague';

// Collections to create
const COLLECTIONS = [
    { name: 'golfleague-config', partitionKey: '/leagueName' },
    { name: 'golfleague-scores', partitionKey: '/leagueName' },
    { name: 'golfleague-skinresults', partitionKey: '/leagueName' },
    { name: 'golfleague-skinsummary', partitionKey: '/leagueName' }
];

// Helper function to create authorization header
function getAuthorizationHeader(verb, resourceType, resourceId, date) {
    const key = Buffer.from(COSMOS_KEY, 'base64');
    const text = `${verb.toLowerCase()}\n${resourceType.toLowerCase()}\n${resourceId}\n${date.toLowerCase()}\n\n`;
    const signature = crypto.createHmac('sha256', key).update(text, 'utf8').digest('base64');
    return `type=master&ver=1.0&sig=${encodeURIComponent(signature)}`;
}

// Helper function to make HTTPS requests
function makeRequest(options, data = null) {
    return new Promise((resolve, reject) => {
        // Disable SSL verification for local emulator
        process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;
        
        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve({ statusCode: res.statusCode, body: JSON.parse(body || '{}') });
                } else {
                    reject(new Error(`HTTP ${res.statusCode}: ${body}`));
                }
            });
        });
        
        req.on('error', reject);
        
        if (data) {
            req.write(JSON.stringify(data));
        }
        req.end();
    });
}

// Create database
async function createDatabase() {
    console.log(`Creating database: ${DATABASE_NAME}`);
    
    const date = new Date().toUTCString();
    const auth = getAuthorizationHeader('POST', 'dbs', '', date);
      const options = {
        hostname: '127.0.0.1',
        port: 8081,
        path: '/dbs',
        method: 'POST',
        headers: {
            'Authorization': auth,
            'x-ms-date': date,
            'x-ms-version': '2018-12-31',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    };
    
    try {
        const result = await makeRequest(options, { id: DATABASE_NAME });
        console.log(`✅ Database created successfully: ${DATABASE_NAME}`);
        return result;
    } catch (error) {
        if (error.message.includes('409')) {
            console.log(`ℹ️  Database already exists: ${DATABASE_NAME}`);
            return { statusCode: 409 };
        }
        throw error;
    }
}

// Create collection
async function createCollection(collectionName, partitionKey) {
    console.log(`Creating collection: ${collectionName}`);
    
    const date = new Date().toUTCString();
    const resourceId = `dbs/${DATABASE_NAME}`;
    const auth = getAuthorizationHeader('POST', 'colls', resourceId, date);
      const options = {
        hostname: '127.0.0.1',
        port: 8081,
        path: `/dbs/${DATABASE_NAME}/colls`,
        method: 'POST',
        headers: {
            'Authorization': auth,
            'x-ms-date': date,
            'x-ms-version': '2018-12-31',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    };
    
    const collectionData = {
        id: collectionName,
        partitionKey: {
            paths: [partitionKey],
            kind: 'Hash'
        }
    };
    
    try {
        const result = await makeRequest(options, collectionData);
        console.log(`✅ Collection created successfully: ${collectionName}`);
        return result;
    } catch (error) {
        if (error.message.includes('409')) {
            console.log(`ℹ️  Collection already exists: ${collectionName}`);
            return { statusCode: 409 };
        }
        throw error;
    }
}

// Main setup function
async function setupCosmosDB() {
    console.log('🚀 Setting up Cosmos DB for Golf League...\n');
    
    try {
        // Create database
        await createDatabase();
        
        // Create collections
        for (const collection of COLLECTIONS) {
            await createCollection(collection.name, collection.partitionKey);
        }
        
        console.log('\n✅ Cosmos DB setup completed successfully!');
        console.log('\n📊 Summary:');
        console.log(`   Database: ${DATABASE_NAME}`);
        console.log('   Collections:');
        COLLECTIONS.forEach(col => {
            console.log(`     - ${col.name} (partition key: ${col.partitionKey})`);
        });
        
        console.log('\n🌐 Access your data at: https://localhost:8081/_explorer/index.html');
        
    } catch (error) {
        console.error('❌ Error setting up Cosmos DB:', error.message);
        process.exit(1);
    }
}

// Run the setup
setupCosmosDB();
