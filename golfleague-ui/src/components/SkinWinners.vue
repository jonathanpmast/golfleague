<template>
  <div v-if="weekData && recentWinners">
    <h4 class="font-bold pb-2 mt-12 border-b border-gray-200">Skin Winners for {{ formatDate(weekData.roundPlayedDate) }}  </h4>
    <ul class="mt-4 p-2 mb-3 rounded bg-white border-gray-200 shadow-md overflow-hidden">
      <li
        v-for="(hole,idx) in recentWinners"
        :key="idx"
      >
        <span class="font-bold">{{ hole.winnerName }}</span> won <span class="font-bold">{{ formatDollars(hole.amountWon) }}</span> on <span class="font-bold">#{{ hole.holeWon }}</span> with a <span class="font-bold">{{ hole.gross }} net {{ hole.net }}</span>
      </li>
    </ul>    
  </div>

</template>
<script>
import { computed, onMounted } from "vue";
import useSkins from "../common/useSkins";
export default {
  name: 'LastWeekResults',
  props: {
    weekData: Object,
  },

  setup(props) {
    const {getSkinWinners} = useSkins();
    
    const recentWinners = computed(() => getSkinWinners(props.weekData));    
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
    
    const formatDollars = function(number) {
        var formatter = new Intl.NumberFormat('en-US' , {
          style: 'currency',
          currency: 'USD',
        });
        return formatter.format(number);
      };

    return {
      getSkinWinners,
      formatDate,
      formatDollars,
      recentWinners
    };
  }
}
</script>
