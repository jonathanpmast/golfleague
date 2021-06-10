<template>
  <div v-if="skinData">
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
import useSkins from "../common/useSkins"
import SkinResult from "../components/SkinResult.vue"
export default {
    name: "Skins",
    components: {
        SkinResult
    },
    setup() {
      const { loading, error, skinData, loadSkinData } = useSkins();
      const currentSkinResult = computed(() => {
        if(skinData.value && skinData.value.length > 0)
        {
            return skinData.value[0];
        }
        return null;
      });
      onMounted(() => {
        loadSkinData("bmgnky");
      });

      return {
          loading,
          error,
          currentSkinResult,
          skinData
      };
    },
}
</script>
