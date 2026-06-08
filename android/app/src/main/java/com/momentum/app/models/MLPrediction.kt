package com.momentum.app.models

import java.time.LocalDate
import java.util.UUID

data class Prediction(
    val date: LocalDate,
    val predictedEnergy: EnergyLevel,
    val predictedFocus: Int,
    val predictedStress: StressLevel,
    val confidence: Double,
    val keyDriver: String
)

data class Pattern(
    val id: String = UUID.randomUUID().toString(),
    val type: PatternType,
    val description: String,
    val frequency: Double,
    val strength: Double,
    val actionable: Boolean,
    val suggestedAction: MicroAction? = null
)

enum class PatternType(val label: String) {
    Weekly("Weekly"),
    Daily("Daily"),
    Trigger("Trigger"),
    Correlation("Correlation"),
    Anomaly("Anomaly")
}

data class UserProfile(
    var baselineSleep: Double = 7.0,
    var baselineSteps: Int = 5000,
    var baselineHRV: Double = 40.0,
    var effectiveActions: MutableMap<String, Double> = mutableMapOf(),
    var triggerPatterns: MutableMap<String, Double> = mutableMapOf(),
    var daysTracked: Int = 0
)

data class FeatureVector(
    val dayOfWeek: Int,
    val hour: Int,
    val sleepHours: Double,
    val sleepQualityScore: Int,
    val steps: Int,
    val heartRateAvg: Double,
    val heartRateVariability: Double,
    val screenTimeMinutes: Double,
    val calendarIntensity: Int,
    val previousDayEnergy: Int,
    val previousDayStress: Int,
    val previousDayFocus: Int,
    val weekToDateSleepAvg: Double,
    val weekToDateStepsAvg: Int,
    val monthToDateFocusAvg: Int
)
