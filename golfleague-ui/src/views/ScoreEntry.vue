<template>
  <div class="max-w-6xl mx-auto p-6">
    <h1 class="text-2xl font-bold text-gray-900 mb-4">
      Score Entry
    </h1>
    
    <!-- Round Information -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <h2 class="text-lg font-semibold text-gray-900 mb-4">
        Round Information
      </h2>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label
            for="date"
            class="block text-sm font-medium text-gray-700 mb-1"
          >
            Date
          </label>
          <input
            id="date"
            v-model="roundData.date"
            type="date"
            class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>
        <div>
          <label
            for="round"
            class="block text-sm font-medium text-gray-700 mb-1"
          >
            Round Number
          </label>
          <input
            id="round"
            v-model.number="roundData.roundNumber"
            type="number"
            min="1"
            class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>
        <div>
          <label
            for="course"
            class="block text-sm font-medium text-gray-700 mb-1"
          >
            Course
          </label>
          <input
            id="course"
            v-model="roundData.course"
            type="text"
            class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>
      </div>
    </div>

    <!-- Player Selection -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <h2 class="text-lg font-semibold text-gray-900 mb-4">
        Select Players
      </h2>
      <div class="space-y-2 mb-4">
        <div
          v-for="player in availablePlayers"
          :key="player.id"
          class="flex items-center"
        >
          <input
            :id="`player-${player.id}`"
            v-model="selectedPlayerIds"
            type="checkbox"
            :value="player.id"
            class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
          >
          <label
            :for="`player-${player.id}`"
            class="ml-2 text-sm text-gray-700"
          >
            {{ player.name }}
          </label>
        </div>
      </div>

      <!-- Add New Player -->
      <div class="border-t pt-4">
        <div class="flex gap-2">
          <input
            v-model="newPlayerName"
            type="text"
            placeholder="Add new player..."
            class="flex-1 p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
          <button
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            @click="addNewPlayer"
          >
            Add Player
          </button>
        </div>
      </div>
    </div>    <!-- Score Entry Grid -->
    <div
      v-if="selectedPlayers.length > 0"
      class="bg-white rounded-lg shadow p-6"
    >
      <h2 class="text-lg font-semibold text-gray-900 mb-4">
        Enter Scores (9-hole league - complete either holes 1-9 OR 10-18)
      </h2>
      <div class="overflow-x-auto">
        <table class="w-full border-collapse">
          <thead>
            <tr class="bg-gray-50">
              <th class="text-left py-2 px-3 font-medium text-gray-700">
                Player
              </th>
              <th
                v-for="hole in 9"
                :key="hole"
                class="text-center py-2 px-2 font-medium text-gray-700 min-w-[50px] border-r-2 border-blue-200"
              >
                {{ hole }}
              </th>
              <th class="text-center py-2 px-2 font-medium text-gray-600 text-sm">
                Front 9
              </th>
              <th
                v-for="hole in 9"
                :key="hole + 9"
                class="text-center py-2 px-2 font-medium text-gray-700 min-w-[50px]"
              >
                {{ hole + 9 }}
              </th>
              <th class="text-center py-2 px-2 font-medium text-gray-600 text-sm">
                Back 9
              </th>
              <th class="text-center py-2 px-3 font-medium text-gray-700">
                Total
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="player in selectedPlayers"
              :key="player.id"
              class="border-b hover:bg-gray-50"
            >
              <td class="py-2 px-3 font-medium text-gray-900">
                {{ player.name }}
              </td>
              <!-- Front 9 -->
              <td
                v-for="hole in 9"
                :key="hole"
                class="py-2 px-2 border-r border-blue-100"
              >
                <input
                  v-model.number="scores[player.id][hole]"
                  type="number"
                  min="1"
                  max="15"
                  class="w-full p-1 text-center border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                  @input="calculateTotal(player.id)"
                >
              </td>
              <td class="py-2 px-2 text-center border-r-2 border-blue-200">
                <span 
                  :class="isNineComplete(player.id, 'front') ? 'text-green-600 font-semibold' : 'text-gray-400'"
                  class="text-sm"
                >
                  {{ getFrontNineTotal(player.id) }}
                  {{ isNineComplete(player.id, 'front') ? '✓' : '' }}
                </span>
              </td>
              <!-- Back 9 -->
              <td
                v-for="hole in 9"
                :key="hole + 9"
                class="py-2 px-2"
              >
                <input
                  v-model.number="scores[player.id][hole + 9]"
                  type="number"
                  min="1"
                  max="15"
                  class="w-full p-1 text-center border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                  @input="calculateTotal(player.id)"
                >
              </td>
              <td class="py-2 px-2 text-center">
                <span 
                  :class="isNineComplete(player.id, 'back') ? 'text-green-600 font-semibold' : 'text-gray-400'"
                  class="text-sm"
                >
                  {{ getBackNineTotal(player.id) }}
                  {{ isNineComplete(player.id, 'back') ? '✓' : '' }}
                </span>
              </td>
              <td class="py-2 px-3 text-center font-medium">
                {{ getPlayerTotal(player.id) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Actions -->
    <div
      v-if="selectedPlayers.length > 0"
      class="bg-white rounded-lg shadow p-6"
    >
      <div class="flex gap-4">
        <button
          class="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500"
          @click="resetScores"
        >
          Reset Scores
        </button>
        <button
          :disabled="!isValid || isSaving"
          class="px-6 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
          @click="saveScores"
        >
          {{ isSaving ? 'Saving...' : 'Save Scores' }}
        </button>
      </div>
      
      <!-- Validation Messages -->
      <div
        v-if="validationMessages.length > 0"
        class="mt-4"
      >
        <div
          v-for="message in validationMessages"
          :key="message"
          class="text-sm"
        >
          <span class="text-red-600">{{ message }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import useConfig from '../common/useConfig'
import { useScores } from '../common/useScores'

export default {
  name: 'ScoreEntry',
  setup() {
    const route = useRoute()
    const config = useConfig()
    const { saveScores, calculateSkins, validateScoreData, formatScoreForAPI, loading: apiLoading } = useScores()
    
    // Get league name from route params, fallback to default
    const leagueName = computed(() => route.params.leagueName || 'bmgnky')
    const roundData = reactive({
      date: new Date().toISOString().split('T')[0],
      roundNumber: 1,
      course: 'Boone Links Golf Course'
    })
      const availablePlayers = ref([])
    const selectedPlayerIds = ref([])
    const newPlayerName = ref('')
    const scores = reactive({})
    const validationMessages = ref([])
    const isValid = ref(false)
    const isSaving = ref(false)
    
    // Computed
    const selectedPlayers = computed(() => {
      return availablePlayers.value.filter(player => 
        selectedPlayerIds.value.includes(player.id)
      )
    })
      // Methods
    const loadPlayers = async () => {
      try {
        // Load config data first
        await config.loadConfigData(leagueName.value)
        
        // Get players from config
        if (config.configData.value?.players) {
          availablePlayers.value = config.configData.value.players.map(player => ({
            id: player.id || player.name,
            name: player.name
          }))
        } else {
          // Default players for demo
          availablePlayers.value = [
            { id: 'player1', name: 'John Doe' },
            { id: 'player2', name: 'Jane Smith' },
            { id: 'player3', name: 'Bob Johnson' },
            { id: 'player4', name: 'Mike Wilson' }
          ]
        }
      } catch (error) {
        console.error('Error loading players:', error)
        // Fallback to default players
        availablePlayers.value = [
          { id: 'player1', name: 'John Doe' },
          { id: 'player2', name: 'Jane Smith' },
          { id: 'player3', name: 'Bob Johnson' },
          { id: 'player4', name: 'Mike Wilson' }
        ]
      }
    }
    
    const addNewPlayer = () => {
      if (newPlayerName.value.trim()) {
        const newPlayer = {
          id: `player_${Date.now()}`,
          name: newPlayerName.value.trim()
        }
        availablePlayers.value.push(newPlayer)
        selectedPlayerIds.value.push(newPlayer.id)
        newPlayerName.value = ''
        initializePlayerScores(newPlayer.id)
      }
    }
    
    const initializePlayerScores = (playerId) => {
      scores[playerId] = {}
      for (let hole = 1; hole <= 18; hole++) {
        scores[playerId][hole] = null
      }
    }
    
    const calculateTotal = (playerId) => {
      // Force reactivity by accessing the reactive object
      const playerScores = scores[playerId]
      if (!playerScores) return 0
      
      let total = 0
      for (let hole = 1; hole <= 18; hole++) {
        const score = playerScores[hole]
        if (score && score > 0) {
          total += score
        }
      }
      return total
    }
      const getPlayerTotal = (playerId) => {
      return calculateTotal(playerId)
    }
    
    const getFrontNineTotal = (playerId) => {
      const playerScores = scores[playerId]
      if (!playerScores) return 0
      
      let total = 0
      for (let hole = 1; hole <= 9; hole++) {
        const score = playerScores[hole]
        if (score && score > 0) {
          total += score
        }
      }
      return total
    }
    
    const getBackNineTotal = (playerId) => {
      const playerScores = scores[playerId]
      if (!playerScores) return 0
      
      let total = 0
      for (let hole = 10; hole <= 18; hole++) {
        const score = playerScores[hole]
        if (score && score > 0) {
          total += score
        }
      }
      return total
    }
    
    const isNineComplete = (playerId, nine) => {
      const playerScores = scores[playerId]
      if (!playerScores) return false
      
      if (nine === 'front') {
        // Check holes 1-9
        for (let hole = 1; hole <= 9; hole++) {
          if (!playerScores[hole] || playerScores[hole] <= 0) {
            return false
          }
        }
        return true
      } else if (nine === 'back') {
        // Check holes 10-18
        for (let hole = 10; hole <= 18; hole++) {
          if (!playerScores[hole] || playerScores[hole] <= 0) {
            return false
          }
        }
        return true
      }
      return false
    }
      const validateScores = () => {
      validationMessages.value = []
      
      // Calculate totals for each player
      const playerTotals = {}
      selectedPlayers.value.forEach(player => {
        playerTotals[player.id] = getPlayerTotal(player.id)
      })
      
      const scoreData = formatScoreForAPI(roundData, selectedPlayers.value, scores, playerTotals)
      const validation = validateScoreData(scoreData)
      
      validationMessages.value = validation.errors
      isValid.value = validation.isValid
      
      return validation.isValid
    }
    
    const resetScores = () => {
      selectedPlayers.value.forEach(player => {
        initializePlayerScores(player.id)
      })
      validationMessages.value = []
    }
      const saveScoresHandler = async () => {
      if (!validateScores()) {
        return
      }
      
      isSaving.value = true
      
      try {
        // Calculate totals for each player
        const playerTotals = {}
        selectedPlayers.value.forEach(player => {
          playerTotals[player.id] = getPlayerTotal(player.id)
        })
        
        const scoreData = formatScoreForAPI(roundData, selectedPlayers.value, scores, playerTotals)
        
        // Save scores
        await saveScores(leagueName.value, scoreData)
        
        // Calculate skins for this round
        const currentYear = new Date().getFullYear()
        await calculateSkins(leagueName.value, currentYear, roundData.roundNumber)
        
        alert('Scores saved and skins calculated successfully!')
        
        // Reset form
        selectedPlayerIds.value = []
        Object.keys(scores).forEach(playerId => delete scores[playerId])
        validationMessages.value = []
        roundData.roundNumber++
        
      } catch (error) {
        console.error('Error saving scores:', error)
        alert('Error saving scores. Please try again.')
      } finally {
        isSaving.value = false
      }
    }
    
    // Watch for player selection changes
    const updateScoresForSelectedPlayers = () => {
      selectedPlayers.value.forEach(player => {
        if (!scores[player.id]) {
          initializePlayerScores(player.id)
        }
      })
    }
    
    // Lifecycle
    onMounted(() => {
      loadPlayers()
    })
      // Watch selectedPlayerIds
    watch(selectedPlayerIds, updateScoresForSelectedPlayers, { immediate: true })
    
    // Watch scores for validation changes
    watch(scores, () => {
      if (selectedPlayers.value.length > 0) {
        validateScores()
      }
    }, { deep: true })
    
    return {
      roundData,
      availablePlayers,
      selectedPlayerIds,
      selectedPlayers,
      newPlayerName,
      scores,
      validationMessages,
      isValid,
      isSaving: computed(() => isSaving.value || apiLoading.value),
      addNewPlayer,
      calculateTotal,
      getPlayerTotal,
      getFrontNineTotal,
      getBackNineTotal,
      isNineComplete,
      validateScores,
      resetScores,
      saveScores: saveScoresHandler
    }
  }
}
</script>
