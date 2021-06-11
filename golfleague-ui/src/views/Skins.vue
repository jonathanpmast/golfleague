<template>
  <div v-if="skinData">
    <h4 class="font-bold pb-2 mt-4 border-b border-gray-200 flex justify-between max-w-md">
      <button
        @click="previousSkinResult"
      >
        <svg
          class="w-6 h-6"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        ><path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M11 19l-7-7 7-7m8 14l-7-7 7-7"
        /></svg>
      </button>
      <span class="px-3">Week {{ currentSkinResult.roundNumber }} - {{ formatDate(currentSkinResult.roundPlayedDate) }}</span>  
      <button
        @click="nextSkinResult"
      >
        <svg
          class="w-6 h-6"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        ><path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M13 5l7 7-7 7M5 5l7 7-7 7"
        /></svg>
      </button>
    </h4>   
    <skin-result :skin-result-data="currentSkinResult" />
  </div>
  <p v-if="loading">
    Still loading..
  </p>
  <p v-if="error">
    {{ error }}
  </p> 
</template>
<script>
import { computed, onMounted } from "vue"; 
import useUtils from "../common/useUtils";
import useSkins from "../common/useSkins";
import SkinResult from "../components/SkinResult.vue";
import { useRoute, useRouter } from 'vue-router';

const checkRouteParams = function(params) {
  if(!params.year || !params.round)
    return false;
  return true;
}

export default {
    name: "Skins",
    components: {
        SkinResult
    },

    setup() {
      const { loading, error, skinData, loadSkinData, findSkinDataIndex, navToSkinResult } = useSkins();
      const { formatDate } = useUtils();
      
      const route = useRoute();
      const router = useRouter();
      let currentSkinIndex = 0;
      
      const currentSkinResult = computed(() => {
        if(skinData.value && skinData.value.length > 0)
        {
            if(checkRouteParams(route.params)) {
              
              currentSkinIndex = findSkinDataIndex(route.params.year, route.params.round);
              return skinData.value[currentSkinIndex];
            }
            else {
              currentSkinIndex = 0;
              return skinData.value[0];
            }
        }
        return null;
      });
      onMounted(() => {
        loadSkinData("bmgnky");
      });
      
      const nextSkinResult = function() {
        let targetSkinData = null;
        if(currentSkinIndex > 0)
          targetSkinData = skinData.value[currentSkinIndex-1];
        else
          targetSkinData = skinData.value[skinData.value.length - 1];
        navToSkinResult(targetSkinData, router);
      };

      const previousSkinResult = function() {
        let targetSkinData = null;
        if(currentSkinIndex < skinData.value.length -1 )
          targetSkinData = skinData.value[currentSkinIndex+1];
        else
          targetSkinData = skinData.value[0];
        navToSkinResult(targetSkinData,router);
      };

      return {
          loading,
          error,
          currentSkinResult,
          skinData,
          formatDate,
          nextSkinResult,
          previousSkinResult
      };
    },
}
</script>
