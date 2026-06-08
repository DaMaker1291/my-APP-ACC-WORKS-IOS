package com.momentum.app.services

import com.momentum.app.models.Correlation
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.DayScore
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.Insight
import com.momentum.app.models.InsightCategory
import com.momentum.app.models.InsightSeverity
import com.momentum.app.models.MicroAction
import com.momentum.app.models.MicroActionCategory

class InsightEngine {

    fun generateDailyInsights(metrics: DailyMetrics, history: List<DailyMetrics>): List<Insight> {
        val insights = mutableListOf<Insight>()

        if (metrics.sleepHours < 6.0) {
            insights.add(
                Insight(
                    category = InsightCategory.Sleep,
                    severity = InsightSeverity.Warning,
                    title = "Low Sleep Detected",
                    message = "You got only ${String.format("%.1f", metrics.sleepHours)} hours of sleep. This affects cognitive function and recovery.",
                    actionable = true,
                    suggestedAction = MicroAction(
                        title = "Power Nap",
                        description = "Take a 20-minute power nap to boost alertness",
                        category = MicroActionCategory.Rest,
                        durationMinutes = 20,
                        iconName = "moon.zzz"
                    )
                )
            )
        }

        if (metrics.steps < 3000) {
            insights.add(
                Insight(
                    category = InsightCategory.Activity,
                    severity = InsightSeverity.Notice,
                    title = "Low Activity",
                    message = "You've only taken ${metrics.steps} steps today. Light movement can improve energy and focus.",
                    actionable = true,
                    suggestedAction = MicroAction(
                        title = "5 Min Walk",
                        description = "A quick walk around the block",
                        category = MicroActionCategory.Movement,
                        durationMinutes = 5,
                        iconName = "figure.walk"
                    )
                )
            )
        }

        if (metrics.screenTimeMinutes > 360) {
            insights.add(
                Insight(
                    category = InsightCategory.Focus,
                    severity = InsightSeverity.Warning,
                    title = "High Screen Time",
                    message = "Screen time at ${String.format("%.0f", metrics.screenTimeMinutes)} minutes. Take regular breaks to reduce eye strain.",
                    actionable = true,
                    suggestedAction = MicroAction(
                        title = "20-20-20 Rule",
                        description = "Look at something 20 feet away for 20 seconds, every 20 minutes",
                        category = MicroActionCategory.Focus,
                        durationMinutes = 1,
                        iconName = "eye"
                    )
                )
            )
        }

        if (metrics.stressLevel.ordinal >= EnergyLevel.EnergyLevel.High.ordinal) {
            insights.add(
                Insight(
                    category = InsightCategory.Stress,
                    severity = InsightSeverity.Warning,
                    title = "Elevated Stress",
                    message = "Your stress levels are elevated. A quick breathing exercise can help.",
                    actionable = true,
                    suggestedAction = MicroAction(
                        title = "Box Breathing",
                        description = "Breathe in for 4 seconds, hold for 4, out for 4, hold for 4",
                        category = MicroActionCategory.Breathing,
                        durationMinutes = 4,
                        iconName = "wind"
                    )
                )
            )
        }

        if (metrics.energyLevel == EnergyLevel.Low || metrics.energyLevel == EnergyLevel.VeryLow) {
            insights.add(
                Insight(
                    category = InsightCategory.Energy,
                    severity = InsightSeverity.Notice,
                    title = "Low Energy",
                    message = "Energy levels are low. Consider a nutrient-dense snack or short walk.",
                    actionable = true,
                    suggestedAction = MicroAction(
                        title = "Energizing Snack",
                        description = "Try nuts, fruit, or a protein shake",
                        category = MicroActionCategory.Nutrition,
                        durationMinutes = 5,
                        iconName = "leaf"
                    )
                )
            )
        }

        if (history.isNotEmpty()) {
            val sleepCorrelation = findCorrelation(
                history, "sleepHours", "focusScore"
            )
            if (sleepCorrelation != null && sleepCorrelation.strength > 0.5) {
                insights.add(
                    Insight(
                        category = InsightCategory.Sleep,
                        severity = InsightSeverity.Info,
                        title = "Sleep-Focus Link",
                        message = sleepCorrelation.description,
                        correlation = sleepCorrelation,
                        actionable = false
                    )
                )
            }

            val screenCorrelation = findCorrelation(
                history, "screenTimeMinutes", "focusScore"
            )
            if (screenCorrelation != null && screenCorrelation.strength > 0.4) {
                insights.add(
                    Insight(
                        category = InsightCategory.Focus,
                        severity = InsightSeverity.Info,
                        title = "Screen-Focus Link",
                        message = screenCorrelation.description,
                        correlation = screenCorrelation,
                        actionable = true,
                        suggestedAction = MicroAction(
                            title = "Digital Detox",
                            description = "Take a 15-minute break from all screens",
                            category = MicroActionCategory.Focus,
                            durationMinutes = 15,
                            iconName = "iphone.slash"
                        )
                    )
                )
            }
        }

        if (indicatorsImproved(metrics, history)) {
            insights.add(
                Insight(
                    category = InsightCategory.Holistic,
                    severity = InsightSeverity.Notice,
                    title = "Positive Trend",
                    message = "Your overall metrics are improving. Keep up the great work!",
                    actionable = false
                )
            )
        }

        return insights
    }

    fun calculateDayScore(metrics: DailyMetrics): DayScore {
        val sleepScore = ((metrics.sleepHours / 8.0) * 100).toInt().coerceIn(0, 100)
        val activityScore = ((metrics.steps.toDouble() / 7500.0) * 100).toInt().coerceIn(0, 100)
        val focusScore = metrics.focusScore
        val stressScore = (100 - (metrics.stressLevel.ordinal * 25)).coerceIn(0, 100)
        val energyScore = (metrics.energyLevel.ordinal * 25).coerceIn(0, 100)
        val nutritionScore = 60
        val overall = (sleepScore + activityScore + focusScore + stressScore + energyScore + nutritionScore) / 6

        return DayScore(
            date = metrics.date.toString(),
            overall = overall,
            energy = energyScore,
            focus = focusScore,
            stress = stressScore,
            nutrition = nutritionScore,
            activity = activityScore,
            sleep = sleepScore
        )
    }

    private fun findCorrelation(
        history: List<DailyMetrics>,
        metric1: String,
        metric2: String
    ): Correlation? {
        if (history.size < 3) return null

        val getMetric = { m: DailyMetrics, field: String ->
            when (field) {
                "sleepHours" -> m.sleepHours
                "steps" -> m.steps.toDouble()
                "focusScore" -> m.focusScore.toDouble()
                "screenTimeMinutes" -> m.screenTimeMinutes
                "heartRateAvg" -> m.heartRateAvg
                "heartRateVariability" -> m.heartRateVariability
                else -> 0.0
            }
        }

        val values1 = history.map { getMetric(it, metric1) }
        val values2 = history.map { getMetric(it, metric2) }

        if (values1.isEmpty() || values2.isEmpty()) return null

        val n = minOf(values1.size, values2.size)
        val mean1 = values1.take(n).average()
        val mean2 = values2.take(n).average()

        var numerator = 0.0
        var denom1 = 0.0
        var denom2 = 0.0

        for (i in 0 until n) {
            val diff1 = values1[i] - mean1
            val diff2 = values2[i] - mean2
            numerator += diff1 * diff2
            denom1 += diff1 * diff1
            denom2 += diff2 * diff2
        }

        val denom = kotlin.math.sqrt(denom1 * denom2)
        val r = if (denom != 0.0) numerator / denom else 0.0

        val description = when {
            r > 0.5 -> "Strong positive correlation: When $metric1 increases, $metric2 tends to increase."
            r > 0.3 -> "Moderate positive correlation detected."
            r < -0.5 -> "Strong negative correlation: When $metric1 increases, $metric2 tends to decrease."
            r < -0.3 -> "Moderate negative correlation detected."
            else -> null
        }

        return description?.let {
            Correlation(
                firstMetric = metric1,
                secondMetric = metric2,
                strength = r,
                description = it,
                actionable = kotlin.math.abs(r) > 0.5
            )
        }
    }

    private fun indicatorsImproved(metrics: DailyMetrics, history: List<DailyMetrics>): Boolean {
        if (history.size < 3) return false
        val recent = history.takeLast(3)
        val recentAvg = recent.map { it.focusScore }.average()
        return metrics.focusScore > recentAvg + 5
    }
}
