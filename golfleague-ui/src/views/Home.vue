<template>
  <div v-if="skinData" class="ml-2 sm:ml-0">
    <skin-winners
      v-for="n in numberOfSkinWinnerWeeks" 
      :key="n" 
      :week-data="skinData[n-1]"
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
import {ref, onMounted, computed} from 'vue';
import { useRoute } from 'vue-router';

import useSkins from "../common/useSkins";
import SkinWinners from '../components/SkinWinners.vue';

export default {
    name: 'Home',
    components: {
        SkinWinners
    },    setup() {
      const route = useRoute();
      const {loadSkinData, loading, error, skinData} = useSkins();
      const numberOfSkinWinnerWeeks = ref(4);
      
      // Get league name from route params, fallback to default
      const leagueName = computed(() => route.params.leagueName || 'bmgnky');

      onMounted(() => {
        loadSkinData(leagueName.value);
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
