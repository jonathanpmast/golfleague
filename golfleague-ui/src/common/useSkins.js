import {ref, computed} from "vue"
const skinData = ref(null);

export default function useSkins() {
    const debug = false;
    const loading = ref(false);
    const error = ref(null);

    const loadSkinData = async function(leagueName) {
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
                console.log(`skin data loaded`);
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

    const getSkinWinners = function(week) {
        let winners = [];
        for(let j = 0; j < week.summary.holes.length; j++) {
            let summaryHole = week.summary.holes[j];

            if(summaryHole.winner !== "none") {
                let split = summaryHole.winner.split(',');
                let winnerName = split[0].trim();
                if(split.length > 1)
                    winnerName = `${split[1].trim()} ${split[0].trim()}`
                let holeIndex = ((summaryHole.holeNumber-1) % 9 );
                if(debug) {
                    console.log(`getSkinWinners::${winnerName} and holeIndex ${holeIndex}`);
                    console.log(`SummaryHole.holeNumber: ${summaryHole.holeNumber} holeIndex: ${holeIndex}`)
                }
                winners.push (
                    {
                        winnerName : winnerName,
                        winnerShortName: split.length == 1 ? winnerName: winnerName.split(' ')[0][0] +" "+ winnerName.split(' ')[1],
                        holeWon : summaryHole.holeNumber,
                        gross: week.results[summaryHole.winnerIndex].holes[holeIndex].gross,
                        net: week.results[summaryHole.winnerIndex].holes[holeIndex].net,
                        amountWon : week.summary.totalSkinMoney / week.summary.totalSkins
                    }
                )
            }
        }
        return winners;
    }

    const findSkinDataIndex=function(year,round) {
        if(!skinData.value)
            return -1;
        for(let i=0; i<skinData.value.length; i++) {
            let curSkinData = skinData.value[i];
            if(curSkinData.roundYear == year && curSkinData.roundNumber == round) {
                return i;
            }
        }
        throw "no skin data for that year or round!"
    }

    const navToSkinResult = function (skinResult,router) {        
        router.push({name: "Skins", params: {year: skinResult.roundYear, round: skinResult.roundNumber}});
    }

    return {
        loading: computed(() => loading.value),
        error: computed(() => error.value),
        skinData: computed(() => skinData.value),
        loadSkinData,
        getSkinWinners,
        findSkinDataIndex,
        navToSkinResult
    }
}

