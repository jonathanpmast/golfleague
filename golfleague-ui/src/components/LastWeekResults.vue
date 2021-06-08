<template>
  <div v-if="!loading && skinData && recentWinners">
    <h4 class="font-bold pb-2 mt-12 border-b border-gray-200">Skin Results for {{ formatDate(skinData[0].roundPlayedDate) }}  </h4>
    <ul class="mt-4 p-2 mb-3 rounded bg-white border-gray-200 shadow-md overflow-hidden">
      <li
        v-for="(hole,idx) in recentWinners"
        :key="idx"
      >
        <span class="font-bold">{{ hole.winnerName }}</span> won <span class="font-bold">${{ hole.amountWon }}</span> on <span class="font-bold">#{{ hole.holeWon }}</span> with a <span class="font-bold">{{ hole.gross }} net {{ hole.net }}</span>
      </li>
    </ul>    
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
import useSkins from "../common/useSkins";
export default {
  name: 'LastWeekResults',
  props: {
  },
  setup() {
    const {loadSkinData, loading, error, skinData, getSkinWinners} = useSkins();
    const recentWinners = computed(() => {
      return getSkinWinners(skinData.value[0]);
    });
    function fetchData() {
      loadSkinData("bmgnky");
    }

    function hasAWinner(summaryRecord) {
      return summaryRecord.winner !== "none";
    }

    function formatDate(date) {
      return new Date(date).toLocaleDateString(
        'en-us',
        {
          year: 'numeric',
          month: 'long',
          day: 'numeric'
        }
      );
    }
    
    onMounted(() => {
      fetchData();
    });

    return {
      loading,
      error,
      skinData,
      hasAWinner,
      formatDate,
      recentWinners
    };
  }
}
</script>