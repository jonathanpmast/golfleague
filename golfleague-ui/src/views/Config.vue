<template>
  <div class="max-w-6xl mx-auto p-6">
    <h1 class="text-2xl font-bold text-gray-900 mb-4">
      Golf Course Configuration
    </h1>
    
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-8">
      <div class="text-gray-600">Loading configuration...</div>
    </div>
    
    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-md p-4 mb-6">
      <div class="text-red-800">Error: {{ error }}</div>
    </div>
    
    <!-- Configuration Form -->
    <div v-else class="space-y-6">
      <!-- Course Information -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">
          Course Information
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label for="configId" class="block text-sm font-medium text-gray-700 mb-1">
              Config ID
            </label>
            <input
              id="configId"
              v-model="configData.id"
              type="text"
              class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
          </div>
          <div>
            <label for="courseName" class="block text-sm font-medium text-gray-700 mb-1">
              Course Name
            </label>
            <input
              id="courseName"
              v-model="configData.courseData.name"
              type="text"
              class="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
          </div>
        </div>
      </div>

      <!-- Holes Configuration -->
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-lg font-semibold text-gray-900">
            Holes Configuration
          </h2>
          <button
            @click="addHole"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            Add Hole
          </button>
        </div>
        
        <div class="overflow-x-auto">
          <table class="w-full border-collapse">
            <thead>
              <tr class="bg-gray-50">
                <th class="text-left py-2 px-3 font-medium text-gray-700">Hole #</th>
                <th class="text-center py-2 px-3 font-medium text-gray-700">Par</th>
                <th class="text-center py-2 px-3 font-medium text-gray-700">Stroke Index</th>
                <th class="text-center py-2 px-3 font-medium text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(hole, index) in configData.courseData.holes"
                :key="hole.number"
                class="border-b hover:bg-gray-50"
              >
                <td class="py-2 px-3">
                  <input
                    v-model.number="hole.number"
                    type="number"
                    min="1"
                    max="18"
                    class="w-20 p-1 text-center border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                  >
                </td>
                <td class="py-2 px-3">
                  <select
                    v-model.number="hole.par"
                    class="w-20 p-1 text-center border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                  >
                    <option value="3">3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                  </select>
                </td>
                <td class="py-2 px-3">
                  <input
                    v-model.number="hole.strokeIndex"
                    type="number"
                    min="1"
                    max="18"
                    class="w-20 p-1 text-center border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                  >
                </td>
                <td class="py-2 px-3 text-center">
                  <button
                    @click="removeHole(index)"
                    class="px-2 py-1 bg-red-600 text-white text-sm rounded hover:bg-red-700"
                  >
                    Remove
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- Course Statistics -->
        <div class="mt-4 p-3 bg-gray-50 rounded">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div>
              <span class="font-medium">Total Holes:</span> {{ configData.courseData.holes.length }}
            </div>
            <div>
              <span class="font-medium">Total Par:</span> {{ totalPar }}
            </div>
            <div>
              <span class="font-medium">Front 9 Par:</span> {{ front9Par }}
            </div>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex gap-4">
          <button
            @click="loadConfig"
            class="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500"
          >
            Reload Config
          </button>
          <button
            @click="saveConfig"
            :disabled="isSaving"
            class="px-6 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isSaving ? 'Saving...' : 'Save Configuration' }}
          </button>
        </div>
        
        <!-- Validation Messages -->
        <div v-if="validationErrors.length > 0" class="mt-4">          <div
            v-for="validationError in validationErrors"
            :key="validationError"
            class="text-sm text-red-600 mb-1"
          >
            {{ validationError }}
          </div>
        </div>
        
        <!-- Success Message -->
        <div v-if="successMessage" class="mt-4 text-sm text-green-600">
          {{ successMessage }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import useConfig from '../common/useConfig'

export default {
  name: 'CourseConfig',  setup() {
    const route = useRoute()
    const config = useConfig()
    
    // Get league name from route params, fallback to default
    const leagueName = computed(() => route.params.leagueName || 'bmgnky')
    
    const loading = ref(false)
    const error = ref(null)
    const isSaving = ref(false)
    const validationErrors = ref([])
    const successMessage = ref('')
    
    // Default configuration structure
    const defaultConfig = {
      id: '1',
      courseData: {
        name: 'Boone Links Brooke/Lake',
        holes: []
      }
    }
    
    const configData = reactive({ ...defaultConfig })
    
    // Computed properties
    const totalPar = computed(() => {
      return configData.courseData.holes.reduce((sum, hole) => sum + (hole.par || 0), 0)
    })
    
    const front9Par = computed(() => {
      return configData.courseData.holes
        .filter(hole => hole.number <= 9)
        .reduce((sum, hole) => sum + (hole.par || 0), 0)
    })
    
    // Methods
    const loadConfig = async () => {
      loading.value = true
      error.value = null
      successMessage.value = ''
        try {
        await config.loadConfigData(leagueName.value)
        
        if (config.configData.value) {
          // Update reactive data with loaded config
          Object.assign(configData, config.configData.value)
          
          // Ensure holes array exists and is sorted
          if (!configData.courseData.holes) {
            configData.courseData.holes = []
          } else {
            configData.courseData.holes.sort((a, b) => a.number - b.number)
          }
        } else {
          // No config exists, use default with 18 holes
          Object.assign(configData, defaultConfig)
          initializeDefaultHoles()
        }
      } catch (err) {
        error.value = err.message
        console.error('Error loading config:', err)
        
        // Fall back to default config
        Object.assign(configData, defaultConfig)
        initializeDefaultHoles()
      } finally {
        loading.value = false
      }
    }
    
    const initializeDefaultHoles = () => {
      configData.courseData.holes = []
      for (let i = 1; i <= 18; i++) {
        configData.courseData.holes.push({
          number: i,
          par: 4, // Default par
          strokeIndex: i // Default stroke index
        })
      }
    }
    
    const addHole = () => {
      const nextHoleNumber = Math.max(...configData.courseData.holes.map(h => h.number || 0), 0) + 1
      configData.courseData.holes.push({
        number: nextHoleNumber <= 18 ? nextHoleNumber : 1,
        par: 4,
        strokeIndex: nextHoleNumber <= 18 ? nextHoleNumber : 1
      })
      sortHoles()
    }
    
    const removeHole = (index) => {
      configData.courseData.holes.splice(index, 1)
    }
    
    const sortHoles = () => {
      configData.courseData.holes.sort((a, b) => a.number - b.number)
    }
    
    const validateConfig = () => {
      validationErrors.value = []
      
      if (!configData.id) {
        validationErrors.value.push('Config ID is required')
      }
      
      if (!configData.courseData.name) {
        validationErrors.value.push('Course name is required')
      }
      
      if (configData.courseData.holes.length === 0) {
        validationErrors.value.push('At least one hole is required')
      }
      
      // Check for duplicate hole numbers
      const holeNumbers = configData.courseData.holes.map(h => h.number)
      const duplicates = holeNumbers.filter((num, index) => holeNumbers.indexOf(num) !== index)
      if (duplicates.length > 0) {
        validationErrors.value.push(`Duplicate hole numbers: ${[...new Set(duplicates)].join(', ')}`)
      }
      
      // Check for duplicate stroke indexes
      const strokeIndexes = configData.courseData.holes.map(h => h.strokeIndex)
      const dupStrokes = strokeIndexes.filter((idx, index) => strokeIndexes.indexOf(idx) !== index)
      if (dupStrokes.length > 0) {
        validationErrors.value.push(`Duplicate stroke indexes: ${[...new Set(dupStrokes)].join(', ')}`)
      }
      
      // Validate individual holes
      configData.courseData.holes.forEach((hole, index) => {
        if (!hole.number || hole.number < 1 || hole.number > 18) {
          validationErrors.value.push(`Hole ${index + 1}: Invalid hole number`)
        }
        
        if (!hole.par || hole.par < 3 || hole.par > 5) {
          validationErrors.value.push(`Hole ${hole.number}: Par must be 3, 4, or 5`)
        }
        
        if (!hole.strokeIndex || hole.strokeIndex < 1 || hole.strokeIndex > 18) {
          validationErrors.value.push(`Hole ${hole.number}: Stroke index must be 1-18`)
        }
      })
      
      return validationErrors.value.length === 0
    }
    
    const saveConfig = async () => {
      if (!validateConfig()) {
        return
      }
      
      isSaving.value = true
      successMessage.value = ''
      
      try {
        // Sort holes before saving
        sortHoles()
          // Save using the config composable
        await config.saveConfigData(leagueName.value, configData)
        
        successMessage.value = 'Configuration saved successfully!'
        
        // Clear success message after 3 seconds
        setTimeout(() => {
          successMessage.value = ''
        }, 3000)
        
      } catch (err) {
        error.value = err.message
        console.error('Error saving config:', err)
      } finally {
        isSaving.value = false
      }
    }
    
    // Lifecycle
    onMounted(() => {
      loadConfig()
    })
    
    return {
      configData,
      loading,
      error,
      isSaving,
      validationErrors,
      successMessage,
      totalPar,
      front9Par,
      loadConfig,
      addHole,
      removeHole,
      saveConfig
    }
  }
}
</script>
