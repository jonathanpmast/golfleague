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
    <skin-result
      :skin-result-data="currentSkinResult"
      :config-data="configData"
    />
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
import useConfig from "../common/useConfig";
import SkinResult from "../components/SkinResult.vue";
import { useRoute, useRouter } from 'vue-router';

const checkRouteParams = function(params) {
  if(!params.year || !params.round)
    return false;
  return true;
}

export default {
    name: "SkinsPage",
    components: {
        SkinResult
    },    setup() {
      const { loading: skinsLoading, error: skinsLoadingError, skinData, loadSkinData, findSkinDataIndex, navToSkinResult } = useSkins();
      const { loading: configLoading, error: configLoadingError, configData, loadConfigData} = useConfig();
      const { formatDate } = useUtils();
      
      const route = useRoute();
      const router = useRouter();
      
      // Get league name from route params, fallback to default
      const leagueName = computed(() => route.params.leagueName || 'bmgnky')
      
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
      });      onMounted(() => {
        loadSkinData(leagueName.value);
        loadConfigData(leagueName.value);
      });
        const nextSkinResult = function() {
        let targetSkinData = null;
        if(currentSkinIndex > 0)
          targetSkinData = skinData.value[currentSkinIndex-1];
        else
          targetSkinData = skinData.value[skinData.value.length - 1];
        navToSkinResult(targetSkinData, router, leagueName.value);
      };

      const previousSkinResult = function() {
        let targetSkinData = null;
        if(currentSkinIndex < skinData.value.length -1 )
          targetSkinData = skinData.value[currentSkinIndex+1];
        else
          targetSkinData = skinData.value[0];
        navToSkinResult(targetSkinData, router, leagueName.value);
      };

      return {
          loading: computed(() => skinsLoading.value || configLoading.value),
          error: computed(() => skinsLoadingError.value || configLoadingError.value),
          currentSkinResult,
          skinData,
          configData,
          formatDate,
          nextSkinResult,
          previousSkinResult
      };
    },
}
</script>
