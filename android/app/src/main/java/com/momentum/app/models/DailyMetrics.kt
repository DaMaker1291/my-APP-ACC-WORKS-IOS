package com.momentum.app.models

import java.time.LocalDate
import java.util.UUID

data class DailyMetrics(
    val id: String = UUID.randomUUID().toString(),
    val date: LocalDate = LocalDate.now(),
    var sleepHours: Double = 0.0,
    var sleepQuality: SleepQuality = SleepQuality.Average,
    var steps: Int = 0,
    var heartRateAvg: Double = 0.0,
    var heartRateVariability: Double = 0.0,
    var screenTimeMinutes: Double = 0.0,
    var focusScore: Int = 50,
    var energyLevel: EnergyLevel = EnergyLevel.Moderate,
    var stressLevel: StressLevel = StressLevel.Moderate,
    var calendarEventCount: Int = 0,
    var calendarIntensity: CalendarIntensity = CalendarIntensity.Low
)

enum class SleepQuality(val score: Int) {
    Poor(20), Fair(40), Average(50), Good(70), Excellent(90)
}

enum class EnergyLevel {
    VeryLow, Low, Moderate, High, VeryHigh
}

enum class StressLevel {
    Low, Moderate, High, VeryHigh
}

enum class CalendarIntensity {
    Low, Medium, High, Overwhelming
}
