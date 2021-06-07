<template>
    <h1>Skin Results for {{data.roundPlayedDate}}  </h1>
    <div v-if="!loading && data">
        <ul>
          <li v-for="(hole,idx) in data.summary.holes" :key="idx">
            <span v-if="hasAWinner(hole)"> {{idx + 1}} {{hole.winner}} </span>
          </li>
        </ul>    
    </div>

    <p v-if="loading">
    Still loading..
    </p>
    <p v-if="error">
    {{error}}
    </p>
</template>

<script>
import { ref, onMounted } from "vue";
export default {
  name: 'Posts',
  props: {
  },
  setup() {
    const data = ref(null);
    const loading = ref(true);
    const error = ref(null);

    function fetchData() {
      loading.value = true;
      return fetch('https://func-eus2-golfleague.azurewebsites.net/bmgnky/skins', {
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
            // set the response data
            console.log(json[0]);
            data.value = json[0];
        })
        .catch(err => {
            error.value = err;
            // In case a custom  JSON error response was provied
            if(err.json) {
                return err.json.then(json => { 
                    // set the JSON response message
                    err.rvalue.message = json.message;
                });
            }
        })
        .then(() => {
            loading.value = false;
        })
    }

    function hasAWinner(summaryRecord) {
      return summaryRecord.winner !== "none";
    }
    
    onMounted(() => {
      fetchData();
    });

    return {
      data,
      loading,
      error,
      hasAWinner
    };
  }
}
</script>