package com.momentum.app.ml

import android.content.Context
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.ExerciseReel
import com.momentum.app.models.ReelCategory
import com.momentum.app.services.DataService

class PersonalizedReelScorer(private val context: Context) {

    private val dataService = DataService(context)

    private val allReels = listOf(
        ExerciseReel("Morning Stretch", "Gentle full-body wake-up stretch", "5 min", ReelCategory.Stretch, "figure.flexibility", "#81C784", "Improves circulation and reduces morning stiffness."),
        ExerciseReel("Quick Cardio", "Get your heart pumping fast", "7 min", ReelCategory.Cardio, "heart.fill", "#FF8A65", "7 minutes of HIIT boosts metabolism for hours."),
        ExerciseReel("Desk Yoga", "Release tension from sitting", "10 min", ReelCategory.Yoga, "figure.yoga", "#BA68C8", "Counteracts the effects of prolonged sitting."),
        ExerciseReel("Power Walk", "Energizing walking routine", "15 min", ReelCategory.Walk, "figure.walk", "#4FC3F7", "Walking in nature reduces rumination by 60%."),
        ExerciseReel("Core Builder", "Strengthen your midsection", "12 min", ReelCategory.Strength, "figure.core.training", "#FFD54F", "Strong core improves posture and reduces back pain."),
        ExerciseReel("Breath & Relax", "Calming breathing sequence", "5 min", ReelCategory.Mindful, "wind", "#A5D6A7", "Deep breathing activates the vagus nerve."),
        ExerciseReel("HIIT Sprint", "High intensity interval burst", "8 min", ReelCategory.HIIT, "flame.fill", "#FF7043", "HIIT increases VO2 max more effectively than steady-state cardio."),
        ExerciseReel("Full Body Strength", "Complete body workout", "20 min", ReelCategory.Strength, "dumbbell.fill", "#CE93D8", "Strength training improves insulin sensitivity."),
        ExerciseReel("Evening Yoga", "Wind down for better sleep", "15 min", ReelCategory.Yoga, "moon.stars.fill", "#7986CB", "Evening yoga improves sleep quality by 40%."),
        ExerciseReel("Stretch Break", "Quick desk stretch routine", "3 min", ReelCategory.Stretch, "figure.cooldown", "#80DEEA", "Frequent breaks improve productivity by 17%.")
    )

    fun scoreReels(metrics: DailyMetrics, history: List<DailyMetrics>): List<ExerciseReel> {
        val energy = metrics.energyLevel.ordinal
        val stress = metrics.stressLevel.ordinal
        val steps = metrics.steps

        return allReels.map { reel ->
            var score = 0.5

            when (reel.category) {
                ReelCategory.Stretch -> {
                    if (energy <= EnergyLevel.Moderate.ordinal) score += 0.3
                    if (steps < 3000) score += 0.2
                }
                ReelCategory.Cardio, ReelCategory.HIIT -> {
                    if (energy >= EnergyLevel.High.ordinal) score += 0.3
                    if (steps > 5000) score += 0.1
                }
                ReelCategory.Yoga -> {
                    if (stress >= com.momentum.app.models.StressLevel.Moderate.ordinal) score += 0.3
                    if (energy <= EnergyLevel.Moderate.ordinal) score += 0.2
                }
                ReelCategory.Walk -> {
                    if (energy <= EnergyLevel.Moderate.ordinal) score += 0.2
                    if (steps < 5000) score += 0.2
                }
                ReelCategory.Mindful -> {
                    if (stress >= com.momentum.app.models.StressLevel.High.ordinal) score += 0.4
                    score += 0.1
                }
                ReelCategory.Strength -> {
                    if (energy >= EnergyLevel.High.ordinal) score += 0.2
                    if (steps > 5000) score += 0.1
                }
            }

            if (history.isNotEmpty()) {
                val lastWeek = history.takeLast(7)
                val strengthCount = lastWeek.count { it.energyLevel.ordinal >= EnergyLevel.High.ordinal }
                if (strengthCount < 2 && reel.category in listOf(ReelCategory.Strength, ReelCategory.HIIT, ReelCategory.Cardio)) {
                    score -= 0.2
                }
            }

            reel to score.coerceIn(0.0, 1.0)
        }.sortedByDescending { it.second }.map { it.first }
    }

    fun getTopReels(metrics: DailyMetrics, history: List<DailyMetrics>, limit: Int = 6): List<ExerciseReel> {
        return scoreReels(metrics, history).take(limit)
    }
}
