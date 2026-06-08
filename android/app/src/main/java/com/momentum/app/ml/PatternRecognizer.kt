package com.momentum.app.ml

import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.MicroAction
import com.momentum.app.models.MicroActionCategory
import com.momentum.app.models.Pattern
import com.momentum.app.models.PatternType

class PatternRecognizer(private val featureStore: FeatureStore) {

    fun detectAll(history: List<DailyMetrics>): List<Pattern> {
        val patterns = mutableListOf<Pattern>()

        detectWeekly(history)?.let { patterns.add(it) }
        detectTrigger(history)?.let { patterns.add(it) }
        detectSleepCorrelation(history)?.let { patterns.add(it) }
        detectAnomaly(history)?.let { patterns.add(it) }
        detectCalendarPattern(history)?.let { patterns.add(it) }

        return patterns
    }

    private fun detectWeekly(history: List<DailyMetrics>): Pattern? {
        if (history.size < 14) return null

        val mondays = history.filter { it.date.dayOfWeek.value == 1 }
        if (mondays.size < 2) return null

        val mondayStress = mondays.map { it.stressLevel.ordinal }.average()
        val avgStress = history.map { it.stressLevel.ordinal }.average()

        if (mondayStress > avgStress + 0.5) {
            return Pattern(
                type = PatternType.Weekly,
                description = "Stress levels are highest on Mondays. Consider a gentle start to your week.",
                frequency = mondays.size.toDouble() / history.size,
                strength = mondayStress - avgStress,
                actionable = true,
                suggestedAction = MicroAction(
                    title = "Monday Morning Stretch",
                    description = "Start your Monday with a 5-minute stretching routine",
                    category = MicroActionCategory.Movement,
                    durationMinutes = 5,
                    iconName = "figure.flexibility"
                )
            )
        }

        return null
    }

    private fun detectTrigger(history: List<DailyMetrics>): Pattern? {
        if (history.size < 5) return null

        val highStressDays = history.filter {
            it.stressLevel.ordinal >= com.momentum.app.models.StressLevel.High.ordinal
        }
        if (highStressDays.isEmpty()) return null

        val highStressScreenTime = highStressDays.map { it.screenTimeMinutes }.average()
        val lowStressScreenTime = history.filter {
            it.stressLevel.ordinal < com.momentum.app.models.StressLevel.High.ordinal
        }.map { it.screenTimeMinutes }.average()

        if (highStressScreenTime > lowStressScreenTime + 120) {
            return Pattern(
                type = PatternType.Trigger,
                description = "High screen time (>${String.format("%.0f", highStressScreenTime)} min) correlates with elevated stress.",
                frequency = highStressDays.size.toDouble() / history.size,
                strength = (highStressScreenTime - lowStressScreenTime) / 480.0,
                actionable = true,
                suggestedAction = MicroAction(
                    title = "Screen Break",
                    description = "Try a 10-minute screen break when you feel stressed",
                    category = MicroActionCategory.Focus,
                    durationMinutes = 10,
                    iconName = "eye"
                )
            )
        }

        return null
    }

    private fun detectSleepCorrelation(history: List<DailyMetrics>): Pattern? {
        if (history.size < 5) return null

        val pairs = history.map { it.sleepHours to it.focusScore }
        if (pairs.size < 5) return null

        val r = pearsonCorrelation(pairs.map { it.first }, pairs.map { it.second })

        if (r > 0.5) {
            return Pattern(
                type = PatternType.Correlation,
                description = "Strong correlation detected: more sleep → better focus (r=${String.format("%.2f", r)})",
                frequency = 1.0,
                strength = r,
                actionable = true,
                suggestedAction = MicroAction(
                    title = "Sleep Optimization",
                    description = "Try going to bed 30 minutes earlier tonight",
                    category = MicroActionCategory.Rest,
                    durationMinutes = 30,
                    iconName = "moon.zzz"
                )
            )
        }

        return null
    }

    private fun detectAnomaly(history: List<DailyMetrics>): Pattern? {
        if (history.size < 7) return null

        val recent = history.takeLast(7)
        val focusScores = recent.map { it.focusScore }
        val mean = focusScores.average()
        val std = kotlin.math.sqrt(focusScores.map { (it - mean) * (it - mean) }.average())

        val anomaly = recent.find { metrics ->
            kotlin.math.abs(metrics.focusScore - mean) > 2 * std
        }

        return anomaly?.let {
            val isPositive = it.focusScore > mean
            Pattern(
                type = PatternType.Anomaly,
                description = if (isPositive) "Unusually high focus day detected! (+${String.format("%.0f", it.focusScore - mean)} pts vs average)"
                else "Unusually low focus day detected. (-${String.format("%.0f", mean - it.focusScore)} pts vs average)",
                frequency = 1.0 / history.size,
                strength = kotlin.math.abs(it.focusScore - mean) / 100.0,
                actionable = !isPositive,
                suggestedAction = if (!isPositive) MicroAction(
                    title = "Focus Reset",
                    description = "Try a 5-minute breathing exercise to reset your focus",
                    category = MicroActionCategory.Breathing,
                    durationMinutes = 5,
                    iconName = "brain"
                ) else null
            )
        }
    }

    private fun detectCalendarPattern(history: List<DailyMetrics>): Pattern? {
        if (history.size < 5) return null

        val highCalendarDays = history.filter {
            it.calendarIntensity.ordinal >= com.momentum.app.models.CalendarIntensity.High.ordinal
        }
        if (highCalendarDays.isEmpty()) return null

        val afterHighCalendar = history.filter { day ->
            history.any { prev ->
                prev.date == day.date.minusDays(1) &&
                    prev.calendarIntensity.ordinal >= com.momentum.app.models.CalendarIntensity.High.ordinal
            }
        }

        if (afterHighCalendar.isNotEmpty()) {
            val avgFocusAfter = afterHighCalendar.map { it.focusScore }.average()
            val avgNormalFocus = history.filter { it !in afterHighCalendar }
                .map { it.focusScore }.average()

            if (avgFocusAfter < avgNormalFocus - 5) {
                return Pattern(
                    type = PatternType.Correlation,
                    description = "Heavy calendar days reduce next-day focus by ${String.format("%.0f", avgNormalFocus - avgFocusAfter)} points.",
                    frequency = highCalendarDays.size.toDouble() / history.size,
                    strength = (avgNormalFocus - avgFocusAfter) / 100.0,
                    actionable = true,
                    suggestedAction = MicroAction(
                        title = "Calendar Buffer",
                        description = "Schedule 15-minute buffer between meetings tomorrow",
                        category = MicroActionCategory.Environment,
                        durationMinutes = 15,
                        iconName = "calendar.badge.clock"
                    )
                )
            }
        }

        return null
    }

    private fun pearsonCorrelation(x: List<Double>, y: List<Double>): Double {
        val n = minOf(x.size, y.size)
        if (n < 3) return 0.0

        val meanX = x.take(n).average()
        val meanY = y.take(n).average()

        var num = 0.0
        var denX = 0.0
        var denY = 0.0

        for (i in 0 until n) {
            val dx = x[i] - meanX
            val dy = y[i] - meanY
            num += dx * dy
            denX += dx * dx
            denY += dy * dy
        }

        val den = kotlin.math.sqrt(denX * denY)
        return if (den != 0.0) num / den else 0.0
    }
}
