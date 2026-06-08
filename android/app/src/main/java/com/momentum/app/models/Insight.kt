package com.momentum.app.models

import java.util.UUID

data class Insight(
    val id: String = UUID.randomUUID().toString(),
    val category: InsightCategory,
    val severity: InsightSeverity,
    val title: String,
    val message: String,
    val actionable: Boolean = false,
    val suggestedAction: MicroAction? = null,
    val correlation: Correlation? = null,
    val timestamp: Long = System.currentTimeMillis()
)

enum class InsightCategory {
    Sleep, Activity, Nutrition, Focus, Stress, Energy, Calendar, Pattern, Holistic
}

enum class InsightSeverity(val score: Int) {
    Info(1), Notice(2), Warning(3), Critical(4)
}

data class MicroAction(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String,
    val category: MicroActionCategory,
    val durationMinutes: Int = 5,
    val energyCost: EnergyLevel = EnergyLevel.Low,
    val iconName: String = "sparkles"
)

enum class MicroActionCategory {
    Breathing, Movement, Nutrition, Focus, Rest, Social, Environment
}

data class Correlation(
    val firstMetric: String,
    val secondMetric: String,
    val strength: Double,
    val description: String,
    val actionable: Boolean = false
)

data class DayScore(
    val date: String,
    val overall: Int,
    val energy: Int,
    val focus: Int,
    val stress: Int,
    val nutrition: Int,
    val activity: Int,
    val sleep: Int
)
