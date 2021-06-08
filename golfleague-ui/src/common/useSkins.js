import {ref, computed} from "vue"

const skinData = ref(null);

export default function useSkins() {
    const debug = true;
    const loading = ref(false);
    const error = ref(null);

    async function loadSkinData(leagueName) {
        if(skinData.value){
            if(debug) {
                console.log(`skinData already loaded, skipping load`);
            }    
            return;
        }
        if(debug) 
            console.log(`loading skin data for ${leagueName}`);
        loading.value = true;
        return fetch(`https://func-eus2-golfleague.azurewebsites.net/${leagueName}/skins`, {
            method: 'get',
            headers: {
                'content-type': 'application/json'
            }
        })
        .then(res => {
            // a non-200 response code
            if(!res.ok) {
                // create error instance with HTTP status
                const error = new Error(res.statusText);
                error.json = res.json();
                throw error;
            }

            return res.json();
        })
        .then(json => {
            // set the response 
            if(debug)
                console.log(`skin data loaded for ${json}`);
            skinData.value = json;
        })
        .catch(err => {
            error.value = err;
            // In case a custom JSON error response was provied
            if(err.json) {
                return err.json.then(json => { 
                    // set the JSON response message
                    error.value = json.message;
                });
            }
        })
        .then(() => {
            loading.value = false;
        })
    }  

    function getSkinWinners(week) {
        let winners = [];
        for(let j = 0; j < week.summary.holes.length; j++) {
            let summaryHole = week.summary.holes[j];

            if(summaryHole.winner !== "none") {
                let winnerName = `${summaryHole.winner.split(',')[1].trim()} ${summaryHole.winner.split(',')[0].trim()}`
                let holeIndex = (summaryHole.holeNumber-1 % 9 );
                if(debug)
                    console.log(`getSkinWinners::${winnerName} and holeIndex ${holeIndex}`);
                winners.push (
                    {
                        winnerName : winnerName,
                        holeWon : summaryHole.holeNumber,
                        gross: week.results[summaryHole.winner][holeIndex].gross,
                        net: week.results[summaryHole.winner][holeIndex].net,
                        amountWon : week.summary.totalSkinMoney / week.summary.totalSkins
                    }
                )
            }
        }
        return winners;
    }

    return {
        loading: computed(() => loading.value),
        error: computed(() => error.value),
        skinData: computed(() => skinData.value),
        loadSkinData,
        getSkinWinners
    }
}

