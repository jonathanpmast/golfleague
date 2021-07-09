<template>
  <div
    v-if="weekData && recentWinners"
    class="max-w-md"
  >
    <h4
      v-if="showHeader"
      class="font-bold pb-2 mt-4 border-b border-gray-200"
    >
      Skin Winners for {{ formatDate(weekData.roundPlayedDate) }}
    </h4>
    <ul 
      v-if="showWinners" 
      class="mt-4 p-2 mb-3 rounded bg-white border-gray-200 shadow-md overflow-hidden"
    >
      <li
        v-for="(hole,idx) in recentWinners"
        :key="idx"
        class="text-sm md:text-base"
      >
        <span class="font-bold">
          <responsive-golfer-name
            :name="hole.winnerName"
            :short-name="hole.winnerShortName"
          />
        </span> won <span class="font-bold">{{ formatDollars(hole.amountWon) }}</span> on <span class="font-bold">#{{ hole.holeWon }}</span> with a <span class="font-bold">{{ hole.gross }} net {{ hole.net }}</span>
      </li>
    </ul>
    <p
      v-if="!showWinners"
      class="mt-4 p-2 mb-3 rounded bg-white border-gray-200 shadow-md overflow-hidden"
    >
      No winners this week!  Megaskins coming up next week!
    </p>    
  </div>
</template>
<script>
import { computed } from "vue";
import useSkins from "../common/useSkins";
import useUtils from "../common/useUtils";
import ResponsiveGolferName from "../components/ResponsiveGolferName.vue"
export default {
  name: 'LastWeekResults',
  components: {
    ResponsiveGolferName
  },
  props: {
    weekData: {
      type: Object,
      default() {
        return null;
      }
    },
    showHeader: {
      type: Boolean,
      default() {
        return true;
      }
    }
  },
  setup(props) {
    const {getSkinWinners} = useSkins();
    const {formatDate} = useUtils();
    const recentWinners = computed(() => getSkinWinners(props.weekData));    
    const showWinners = computed(() => recentWinners.value.length > 0);
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
      recentWinners,
      showWinners
    };
  }
}
</script>
