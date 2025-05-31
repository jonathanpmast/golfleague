import { ref } from 'vue'
import { buildApiUrl } from './useUtils'

export function useScores() {
  const scores = ref([])
  const loading = ref(false)
  const error = ref(null)

  const getScores = async (leagueName, year = null, round = null) => {
    loading.value = true
    error.value = null
      try {
      let url = buildApiUrl('Scores', leagueName)
      const params = new URLSearchParams()
      
      if (year) params.append('year', year)
      if (round) params.append('round', round)
      
      if (params.toString()) {
        url += `?${params.toString()}`
      }
      
      const response = await fetch(url)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      scores.value = data
      return data
    } catch (err) {
      error.value = err.message
      console.error('Error fetching scores:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const saveScores = async (leagueName, scoreData) => {
    loading.value = true
    error.value = null
      try {
      const response = await fetch(buildApiUrl('Scores', leagueName), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(scoreData)
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result = await response.json()
      return result
    } catch (err) {
      error.value = err.message
      console.error('Error saving scores:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const calculateSkins = async (leagueName, year, round) => {
    loading.value = true
    error.value = null
      try {
      const response = await fetch(buildApiUrl('CalculateSkinResults', leagueName), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ year, round })
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result = await response.json()
      return result
    } catch (err) {
      error.value = err.message
      console.error('Error calculating skins:', err)
      throw err
    } finally {      loading.value = false
    }
  }

  const validateScoreData = (scoreData) => {
    const errors = []
    
    if (!scoreData.date) {
      errors.push('Date is required')
    }
    
    if (!scoreData.roundNumber || scoreData.roundNumber < 1) {
      errors.push('Valid round number is required')
    }
    
    if (!scoreData.players || scoreData.players.length === 0) {
      errors.push('At least one player is required')
    }
    
    scoreData.players?.forEach((player, index) => {
      if (!player.name) {
        errors.push(`Player ${index + 1}: Name is required`)
      }
      
      if (!player.scores || player.scores.length === 0) {
        errors.push(`${player.name}: No scores entered`)
        return
      }
      
      // Check for valid 9-hole completion (either front 9 or back 9)
      const holesWithScores = player.scores.map(s => s.hole).sort((a, b) => a - b)
      const front9 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
      const back9 = [10, 11, 12, 13, 14, 15, 16, 17, 18]
      
      // Check if ALL front 9 holes have scores
      const hasFront9 = front9.every(hole => holesWithScores.includes(hole))
      // Check if ALL back 9 holes have scores  
      const hasBack9 = back9.every(hole => holesWithScores.includes(hole))
      
      // Allow save if either front 9 OR back 9 is complete
      if (!hasFront9 && !hasBack9) {
        const missingFront9 = front9.filter(hole => !holesWithScores.includes(hole))
        const missingBack9 = back9.filter(hole => !holesWithScores.includes(hole))
        
        if (missingFront9.length <= missingBack9.length) {
          errors.push(`${player.name}: Missing scores for holes ${missingFront9.join(', ')} to complete front 9`)
        } else {
          errors.push(`${player.name}: Missing scores for holes ${missingBack9.join(', ')} to complete back 9`)
        }
      }
      
      player.scores?.forEach(scoreEntry => {
        if (scoreEntry.hole < 1 || scoreEntry.hole > 18) {
          errors.push(`${player.name}: Invalid hole number ${scoreEntry.hole}`)
        }
        
        if (scoreEntry.score < 1 || scoreEntry.score > 15) {
          errors.push(`${player.name}: Invalid score ${scoreEntry.score} for hole ${scoreEntry.hole}`)
        }
      })
    })
    
    return {
      isValid: errors.length === 0,
      errors
    }
  }

  const formatScoreForAPI = (roundData, selectedPlayers, scores, playerTotals) => {
    return {
      date: roundData.date,
      roundNumber: roundData.roundNumber,
      course: roundData.course || 'Boone Links Golf Course',
      players: selectedPlayers.map(player => ({
        name: player.name,
        scores: Object.keys(scores[player.id] || {})
          .map(hole => ({
            hole: parseInt(hole),
            score: scores[player.id][hole] || 0
          }))
          .filter(s => s.score > 0)
          .sort((a, b) => a.hole - b.hole),
        total: playerTotals[player.id] || 0
      }))
    }
  }

  return {
    scores,
    loading,
    error,
    getScores,
    saveScores,
    calculateSkins,
    validateScoreData,
    formatScoreForAPI
  }
}
