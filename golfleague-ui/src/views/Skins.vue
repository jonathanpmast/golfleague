<template>
  <div v-if="skinData">
    <h4 class="font-bold pb-2 mt-4 border-b border-gray-200 flex justify-center sm:justify-start">
      <button @click="previousSkinResult"><svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7"></path></svg></button>
      <span class="px-3">Skin Results for {{formatDate(currentSkinResult.roundPlayedDate)}}</span>  
      <button @click="nextSkinResult"><svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7"></path></svg></button>
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
import { computed, onMounted, ref } from "vue"; 
import useUtils from "../common/useUtils";
import useSkins from "../common/useSkins";
import SkinResult from "../components/SkinResult.vue";
export default {
    name: "Skins",
    components: {
        SkinResult
    },
    setup() {
      const { loading, error, skinData, loadSkinData } = useSkins();
      const { formatDate } = useUtils();
      var currentSkinIndex = ref(0);
      const currentSkinResult = computed(() => {
        if(skinData.value && skinData.value.length > 0)
        {
            return skinData.value[currentSkinIndex.value];
        }
        return null;
      });
      onMounted(() => {
        loadSkinData("bmgnky");
      });

      function nextSkinResult() {
        if(currentSkinIndex.value > 0)
          currentSkinIndex.value--;
      };

      function previousSkinResult() {
        if(currentSkinIndex.value < skinData.value.length -1 )
        {
           currentSkinIndex.value++;
        }
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
