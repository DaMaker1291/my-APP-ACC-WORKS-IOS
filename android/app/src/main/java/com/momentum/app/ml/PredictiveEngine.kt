package com.momentum.app.ml

import com.momentum.app.models.CalendarIntensity
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.Prediction
import com.momentum.app.models.StressLevel

class PredictiveEngine(private val featureStore: FeatureStore) {

    fun predictTomorrow(today: DailyMetrics): Prediction {
        val history = featureStore.loadMetrics()
        val recentDays = history.takeLast(7)

        val predictedEnergy = predictEnergy(today, recentDays)
        val predictedFocus = predictFocus(today, recentDays)
        val predictedStress = predictStress(today, recentDays)
        val confidence = calculateConfidence(recentDays)
        val keyDriver = identifyKeyDriver(today, recentDays)

        return Prediction(
            date = today.date.plusDays(1),
            predictedEnergy = predictedEnergy,
            predictedFocus = predictedFocus,
            predictedStress = predictedStress,
            confidence = confidence,
            keyDriver = keyDriver
        )
    }

    private fun predictEnergy(today: DailyMetrics, recent: List<DailyMetrics>): EnergyLevel {
        var baseScore = today.energyLevel.ordinal.toDouble()

        if (today.sleepHours >= 7.0) baseScore += 0.5
        else if (today.sleepHours < 5.0) baseScore -= 1.0

        if (today.steps < 2000) baseScore -= 0.3

        if (today.calendarIntensity == CalendarIntensity.Overwhelming) baseScore -= 0.8
        else if (today.calendarIntensity == CalendarIntensity.High) baseScore -= 0.4

        if (recent.size >= 3) {
            val recentEnergy = recent.takeLast(3).map { it.energyLevel.ordinal }.average()
            baseScore = (baseScore * 0.4 + recentEnergy * 0.6)
        }

        val corrected = baseScore.coerceIn(0.0, 4.0)
        return EnergyLevel.values()[corrected.toInt()]
    }

    private fun predictFocus(today: DailyMetrics, recent: List<DailyMetrics>): Int {
        var predicted = today.focusScore.toDouble()

        val sleepFactor = (today.sleepHours - 7.0) * 5
        predicted += sleepFactor

        if (today.stressLevel == StressLevel.High || today.stressLevel == StressLevel.VeryHigh) {
            predicted -= 10
        }

        if (today.screenTimeMinutes > 480) predicted -= 5

        if (recent.size >= 3) {
            val recentFocus = recent.takeLast(3).map { it.focusScore }.average()
            predicted = predicted * 0.3 + recentFocus * 0.7
        }

        return predicted.toInt().coerceIn(0, 100)
    }

    private fun predictStress(today: DailyMetrics, recent: List<DailyMetrics>): StressLevel {
        var baseStress = today.stressLevel.ordinal.toDouble()

        if (today.sleepHours < 6.0) baseStress += 0.5
        if (today.sleepHours >= 8.0) baseStress -= 0.3

        if (today.calendarIntensity == CalendarIntensity.Overwhelming) baseStress += 1.0
        else if (today.calendarIntensity == CalendarIntensity.High) baseStress += 0.5

        if (today.steps > 5000) baseStress -= 0.3

        if (recent.size >= 3) {
            val recentStress = recent.takeLast(3).map { it.stressLevel.ordinal }.average()
            baseStress = baseStress * 0.4 + recentStress * 0.6
        }

        val corrected = baseStress.coerceIn(0.0, 3.0)
        return StressLevel.values()[corrected.toInt()]
    }

    private fun calculateConfidence(recent: List<DailyMetrics>): Double {
        if (recent.size < 3) return 0.3
        if (recent.size < 7) return 0.5 + recent.size * 0.05
        return 0.85
    }

    private fun identifyKeyDriver(today: DailyMetrics, recent: List<DailyMetrics>): String {
        if (today.sleepHours < 6.0) return "Sleep deprivation"
        if (today.calendarIntensity == CalendarIntensity.Overwhelming) return "Calendar overload"
        if (today.stressLevel == StressLevel.VeryHigh) return "High stress"
        if (today.steps < 1000) return "Physical inactivity"
        if (today.screenTimeMinutes > 480) return "Excessive screen time"
        if (recent.size >= 3) {
            val sleepAvg = recent.takeLast(3).map { it.sleepHours }.average()
            if (sleepAvg < 6.0) return "Chronic sleep debt"
        }
        return "Balanced factors"
    }
}
