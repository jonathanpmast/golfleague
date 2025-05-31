import { computed, ref } from "vue"
import { buildApiUrl } from "./useUtils"

const configData = ref(null);

export default function useConfig() {
    const debug = false;
    const loading = ref(false);
    const error = ref(null);
    
    const loadConfigData = async(leagueName) => {
        if(configData.value) {
            if(debug) {
                console.log(`configData already loaded, skipping load`);
            }
            return;
        }
        if(debug)
            console.log(`loading config data for ${leagueName}`);
        loading.value = true;
          try {
            // Try local Azure Functions first
            const response = await fetch(buildApiUrl('GetConfig', leagueName), {
                method: 'GET',
                headers: {
                    'content-type': 'application/json'
                }
            });
            
            if (response.ok) {
                const json = await response.json();
                if(debug) console.log('config data loaded from local functions');
                configData.value = json;
                return;
            }
        } catch (localError) {
            if(debug) console.log('Local functions not available, trying cloud endpoint');
        }
          // Fallback to cloud endpoint
        return fetch(buildApiUrl('config', leagueName), {
            method: 'get',
            headers: {
                'content-type':'application/json'
            }
        })
        .then(res => {
            // a non-200 response code
            if(!res.ok) {
                //create error instance with HTTP status
                const error = new Error(res.statusText);
                error.json = res.json();
                throw error;
            }

            return res.json();
        })
        .then( json => {
            //set the response
            if(debug)
                console.log('config data loaded');
            configData.value = json;
        })
        .catch(err => {
            error.value = err;
            //in case a custom json error response was provided
            if(err.json) {
                return err.json.then(json => {
                    error.value = json.message;
                });
            }
        })
        .then(() => {
            loading.value = false;
        });
    }
    
    const saveConfigData = async(leagueName, config) => {
        loading.value = true;
        error.value = null;
          try {
            const response = await fetch(buildApiUrl('SaveConfig', leagueName), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(config)
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const result = await response.json();
            
            // Update local cache
            configData.value = config;
            
            if(debug) console.log('config data saved successfully');
            return result;
        } catch (err) {
            error.value = err.message;
            console.error('Error saving config:', err);
            throw err;
        } finally {
            loading.value = false;
        }
    }
    
    const clearCache = () => {
        configData.value = null;
    }

    return {
        loading: computed(() => loading.value),
        error: computed(() => error.value),
        configData: computed(() => configData.value),
        loadConfigData,
        saveConfigData,
        clearCache
    }
}