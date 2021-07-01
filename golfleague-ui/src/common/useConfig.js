import { computed, ref } from "vue"
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
        return fetch(`https://func-eus2-golfleague.azurewebsites.net/${leagueName}/config`, {
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

    return {
        loading: computed(() => loading.value),
        error: computed(() => error.value),
        configData: computed(() => configData.value),
        loadConfigData
    }
}