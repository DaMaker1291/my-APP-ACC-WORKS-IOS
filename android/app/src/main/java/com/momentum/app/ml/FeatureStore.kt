package com.momentum.app.ml

import android.content.Context
import com.momentum.app.models.CalendarIntensity
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.FeatureVector
import com.momentum.app.models.SleepQuality
import com.momentum.app.models.StressLevel
import com.momentum.app.services.DataService

class FeatureStore(private val context: Context) {

    private val dataService = DataService(context)

    fun buildVector(metrics: DailyMetrics): FeatureVector {
        val history = loadMetrics()
        val weekMetrics = history.filter {
            it.date.isAfter(metrics.date.minusDays(7)) && !it.date.isAfter(metrics.date)
        }
        val monthMetrics = history.filter {
            it.date.isAfter(metrics.date.minusDays(30)) && !it.date.isAfter(metrics.date)
        }

        val weekToDateSleep = if (weekMetrics.isNotEmpty()) {
            weekMetrics.map { it.sleepHours }.average()
        } else metrics.sleepHours

        val weekToDateSteps = if (weekMetrics.isNotEmpty()) {
            weekMetrics.map { it.steps }.average().toInt()
        } else metrics.steps

        val monthToDateFocus = if (monthMetrics.isNotEmpty()) {
            monthMetrics.map { it.focusScore }.average().toInt()
        } else metrics.focusScore

        val previousDay = if (history.isNotEmpty() && history.last().date.isBefore(metrics.date)) {
            history.last()
        } else null

        return FeatureVector(
            dayOfWeek = metrics.date.dayOfWeek.value,
            hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY),
            sleepHours = metrics.sleepHours,
            sleepQualityScore = metrics.sleepQuality.score,
            steps = metrics.steps,
            heartRateAvg = metrics.heartRateAvg,
            heartRateVariability = metrics.heartRateVariability,
            screenTimeMinutes = metrics.screenTimeMinutes,
            calendarIntensity = metrics.calendarIntensity.ordinal,
            previousDayEnergy = previousDay?.energyLevel?.ordinal ?: 2,
            previousDayStress = previousDay?.stressLevel?.ordinal ?: 1,
            previousDayFocus = previousDay?.focusScore ?: 50,
            weekToDateSleepAvg = weekToDateSleep,
            weekToDateStepsAvg = weekToDateSteps,
            monthToDateFocusAvg = monthToDateFocus
        )
    }

    fun ingest(metrics: DailyMetrics) {
        dataService.saveMetrics(metrics)
    }

    fun loadMetrics(): List<DailyMetrics> {
        return dataService.loadAllMetrics().sortedBy { it.date }
    }

    fun loadMetricsForDate(date: java.time.LocalDate): DailyMetrics? {
        return dataService.loadMetrics(date)
    }

    fun recordActionResult(actionId: String, effectiveness: Double) {
        val actionsKey = "action_effectiveness"
        val existing = dataService.getString(actionsKey, "{}")
        val map = mutableMapOf<String, Double>()
        try {
            val entries = existing.removeSurrounding("{", "}")
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
        val current = map[actionId] ?: 0.0
        map[actionId] = (current + effectiveness) / 2.0
        val serialized = map.entries.joinToString(",") { "${it.key}=${it.value}" }
        dataService.saveString(actionsKey, "{$serialized}")
    }

    fun getActionEffectiveness(): Map<String, Double> {
        val key = "action_effectiveness"
        val existing = dataService.getString(key, "{}")
        val map = mutableMapOf<String, Double>()
        try {
            val entries = existing.removeSurrounding("{", "}")
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
}
