<template>
  <div v-if="skinData">
    <skin-winners v-for="n in numberOfSkinWinnerWeeks" :key="n" :weekData="skinData[n-1]" />
    
    <p v-if="loading">
      Still loading..
    </p>
    <p v-if="error">
      {{ error }}
    </p>
  </div>
</template>
<script>
import {ref, onMounted} from 'vue';

import useSkins from "../common/useSkins";
import SkinWinners from '../components/SkinWinners.vue';

export default {
    name: 'Home',
    components: {
        SkinWinners
    },
    setup() {
      const {loadSkinData, loading, error, skinData} = useSkins();
      const numberOfSkinWinnerWeeks = ref(4);

      onMounted(() => {
        loadSkinData("bmgnky");
      });
      
      return{
        numberOfSkinWinnerWeeks,
        loading,
        error,
        skinData,
      };
    }
}
</script>
