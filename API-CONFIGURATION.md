# API Configuration Guide

## Overview

The Golf League application now uses a centralized API configuration system that automatically switches between local development and production environments based on the current hostname.

## Architecture

### Configuration File: `src/common/useUtils.js`

The API configuration is centralized in the `useUtils.js` file, which exports:

- `getApiConfig()` - Returns current environment configuration
- `buildApiUrl(endpoint, leagueName)` - Builds complete API URLs
- `isLocal` - Boolean indicating if running locally

### Environment Detection

The system automatically detects the environment based on `window.location.hostname`:

- **Local Development**: `localhost`, `127.0.0.1`, or empty hostname
- **Production**: Any other hostname (deployed environment)

### Configuration Structure

```javascript
const API_CONFIG = {
    // Local development endpoints
    local: {
        functionsUrl: 'http://localhost:7071',
        cosmosUrl: 'https://127.0.0.1:8081'
    },
    // Production endpoints
    production: {
        functionsUrl: 'https://func-eus2-golfleague.azurewebsites.net',
        cosmosUrl: null // Not used in production
    }
}
```

## Usage in Composables

### Before Refactoring

```javascript
// Hard-coded URLs in each file
const response = await fetch('https://func-eus2-golfleague.azurewebsites.net/bmgnky/skins')
const response = await fetch('http://localhost:7071/GetConfig/bmgnky')
```

### After Refactoring

```javascript
// Centralized configuration
import { buildApiUrl } from './useUtils'

const response = await fetch(buildApiUrl('skins', leagueName))
const response = await fetch(buildApiUrl('GetConfig', leagueName))
```

## Updated Files

### `src/common/useUtils.js`
- ✅ Added centralized API configuration
- ✅ Added environment detection logic
- ✅ Added URL building helpers

### `src/common/useSkins.js`
- ✅ Removed hardcoded Azure URL
- ✅ Now uses `buildApiUrl('skins', leagueName)`

### `src/common/useConfig.js`
- ✅ Removed hardcoded Azure URL
- ✅ Now uses `buildApiUrl('config', leagueName)`
- ✅ Updated both GET and POST operations

### `src/common/useScores.js`
- ✅ Replaced `API_BASE_URL` constant
- ✅ Now uses `buildApiUrl()` for all endpoints
- ✅ Updated GET, POST, and CalculateSkinResults operations

## Environment Behavior

### Local Development
When running on `localhost:3124` (or any local URL):
- API calls go to `http://localhost:7071`
- Cosmos DB connects to `https://127.0.0.1:8081`
- Uses local Azure Functions

### Production Deployment
When deployed to Azure Static Web Apps:
- API calls go to `https://func-eus2-golfleague.azurewebsites.net`
- Uses production Azure Functions
- Uses production Cosmos DB instance

## API Endpoints

All composables now build URLs using the centralized system:

| Endpoint | Local URL | Production URL |
|----------|-----------|----------------|
| Get Config | `http://localhost:7071/GetConfig/{league}` | `https://func-eus2-golfleague.azurewebsites.net/{league}/config` |
| Save Config | `http://localhost:7071/SaveConfig/{league}` | `https://func-eus2-golfleague.azurewebsites.net/{league}/config` |
| Get Scores | `http://localhost:7071/Scores/{league}` | `https://func-eus2-golfleague.azurewebsites.net/{league}/scores` |
| Save Scores | `http://localhost:7071/Scores/{league}` | `https://func-eus2-golfleague.azurewebsites.net/{league}/scores` |
| Get Skins | `http://localhost:7071/skins/{league}` | `https://func-eus2-golfleague.azurewebsites.net/{league}/skins` |
| Calculate Skins | `http://localhost:7071/CalculateSkinResults/{league}` | `https://func-eus2-golfleague.azurewebsites.net/{league}/calculate` |

## Benefits

1. **No More Hardcoded URLs**: All API endpoints are centrally managed
2. **Automatic Environment Detection**: Seamlessly switches between local and production
3. **Easier Maintenance**: Update URLs in one place
4. **Better Development Experience**: Works out of the box in local development
5. **Deployment Ready**: Automatically uses production URLs when deployed

## Testing

### Local Development
1. Start local services: `.\start-dev-environment.ps1`
2. Start Vue app: `cd golfleague-ui && npm run dev`
3. Open browser: `http://localhost:3124`
4. API calls automatically route to `localhost:7071`

### Production Testing
1. Deploy to Azure Static Web Apps
2. API calls automatically route to `func-eus2-golfleague.azurewebsites.net`

## Future Enhancements

- Add environment-specific configuration for different deployment stages (dev, staging, production)
- Add API timeout configuration
- Add retry logic configuration
- Add API key management for different environments
