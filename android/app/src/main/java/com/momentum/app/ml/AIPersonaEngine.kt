package com.momentum.app.ml

import android.content.Context
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.StressLevel
import com.momentum.app.models.UserProfile
import com.momentum.app.services.DataService

class AIPersonaEngine(private val context: Context) {

    private val dataService = DataService(context)

    private val personaKey = "user_persona"

    fun loadProfile(): UserProfile {
        val baselineSleep = dataService.getFloat("baseline_sleep", 7.0f).toDouble()
        val baselineSteps = dataService.getInt("baseline_steps", 5000)
        val baselineHRV = dataService.getFloat("baseline_hrv", 40.0f).toDouble()
        val daysTracked = dataService.getInt("days_tracked", 0)

        val effectiveActions = loadMap("effective_actions")
        val triggerPatterns = loadMap("trigger_patterns")

        return UserProfile(
            baselineSleep = baselineSleep,
            baselineSteps = baselineSteps,
            baselineHRV = baselineHRV,
            effectiveActions = effectiveActions.toMutableMap(),
            triggerPatterns = triggerPatterns.toMutableMap(),
            daysTracked = daysTracked
        )
    }

    fun updateProfile(metrics: DailyMetrics) {
        val profile = loadProfile()
        profile.daysTracked++

        if (profile.baselineSleep == 7.0 && metrics.sleepHours > 0) {
            profile.baselineSleep = metrics.sleepHours
        } else {
            profile.baselineSleep = (profile.baselineSleep * 0.9 + metrics.sleepHours * 0.1)
        }

        if (profile.baselineSteps == 5000 && metrics.steps > 0) {
            profile.baselineSteps = metrics.steps
        } else {
            profile.baselineSteps = (profile.baselineSteps * 0.9 + metrics.steps * 0.1).toInt()
        }

        if (profile.baselineHRV == 40.0 && metrics.heartRateVariability > 0) {
            profile.baselineHRV = metrics.heartRateVariability
        } else {
            profile.baselineHRV = profile.baselineHRV * 0.9 + metrics.heartRateVariability * 0.1
        }

        saveProfile(profile)
    }

    fun generatePersonaSummary(): String {
        val profile = loadProfile()
        val energyTendency = if (profile.baselineSteps > 6000) "active" else "sedentary"
        val sleepTendency = if (profile.baselineSleep >= 7.0) "well-rested" else "sleep-deprived"

        val effectiveCount = profile.effectiveActions.count { it.value > 0.6 }

        return "Persona: $sleepTendency, $energyTendency ($effectiveCount effective strategies found)"
    }

    private fun saveProfile(profile: UserProfile) {
        dataService.saveFloat("baseline_sleep", profile.baselineSleep.toFloat())
        dataService.saveInt("baseline_steps", profile.baselineSteps)
        dataService.saveFloat("baseline_hrv", profile.baselineHRV.toFloat())
        dataService.saveInt("days_tracked", profile.daysTracked)
        saveMap("effective_actions", profile.effectiveActions)
        saveMap("trigger_patterns", profile.triggerPatterns)
    }

    private fun loadMap(key: String): MutableMap<String, Double> {
        val raw = dataService.getString(key, "{}")
        val map = mutableMapOf<String, Double>()
        try {
            val entries = raw.removeSurrounding("{", "}")
                .split(",")
                .filter { it.isNotBlank() }
            entries.forEach { entry ->
                val parts = entry.split("=")
                if (parts.size == 2) {
                    map[parts[0].trim()] = parts[1].trim().toDouble()
                }
            }
        } catch (_: Exception) {
        }
        return map
    }

    private fun saveMap(key: String, map: Map<String, Double>) {
        val serialized = map.entries.joinToString(",") { "${it.key}=${it.value}" }
        dataService.saveString(key, "{$serialized}")
    }
}
