// API Configuration
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

// Determine if we're running locally
const isLocal = window.location.hostname === 'localhost' || 
                window.location.hostname === '127.0.0.1' ||
                window.location.hostname === ''

// Get current API configuration
export function getApiConfig() {
    return isLocal ? API_CONFIG.local : API_CONFIG.production
}

// Helper to build API URLs
export function buildApiUrl(endpoint, leagueName = null) {
    const config = getApiConfig()
    const baseUrl = config.functionsUrl
    
    if (leagueName) {
        return `${baseUrl}/${endpoint}/${leagueName}`
    }
    return `${baseUrl}/${endpoint}`
}

export default function useUtils() {
    function getGolferNames(golferName) {
        var formattedGolferName = "";
        var golferShortName = "";
        var split = golferName.split(',');
        if(split.length === 1) {
            formattedGolferName = golferShortName = golferName
        }
        else {
            let name = `${golferName.split(',')[1].trim()} ${golferName.split(',')[0].trim()}`;
            formattedGolferName= name;
            golferShortName =  name.split(' ')[0][0] +" "+ name.split(' ')[1]  
        }
        return {
            formattedGolferName,
            golferShortName
        }

    }

    function formatDate(date) {
        return new Date(date).toLocaleDateString(
          'en-us',
          {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          }
        );
      }    return {
        getGolferNames,
        formatDate,
        getApiConfig,
        buildApiUrl,
        isLocal
    }
}