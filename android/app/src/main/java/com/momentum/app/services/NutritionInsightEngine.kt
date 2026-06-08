package com.momentum.app.services

import com.momentum.app.models.FoodEntry
import com.momentum.app.models.Insight
import com.momentum.app.models.InsightCategory
import com.momentum.app.models.InsightSeverity
import com.momentum.app.models.MealType

class NutritionInsightEngine {

    fun generateInsights(entries: List<FoodEntry>): List<Insight> {
        val insights = mutableListOf<Insight>()

        if (entries.isEmpty()) return insights

        val todayEntries = entries.filter {
            isToday(it.timestamp)
        }

        val totalCalories = todayEntries.sumOf { it.calories }
        val totalProtein = todayEntries.sumOf { it.protein }
        val mealCount = todayEntries.distinctBy { it.mealType }.size

        if (totalCalories < 800 && mealCount >= 1) {
            insights.add(
                Insight(
                    category = InsightCategory.Nutrition,
                    severity = InsightSeverity.Warning,
                    title = "Low Calorie Intake",
                    message = "You've only consumed $totalCalories calories today. Try to eat at least 1500-2000 calories for sustained energy.",
                    actionable = true
                )
            )
        }

        if (totalProtein < 30 && totalCalories > 500) {
            insights.add(
                Insight(
                    category = InsightCategory.Nutrition,
                    severity = InsightSeverity.Notice,
                    title = "Protein Deficit",
                    message = "Your protein intake ($totalProtein g) is low. Aim for at least 50g of protein daily to support muscle health.",
                    actionable = true
                )
            )
        }

        val mealTypeCounts = todayEntries.groupBy { it.mealType }
        if (mealTypeCounts[MealType.Breakfast].orEmpty().isEmpty() && !todayEntries.isEmpty()) {
            insights.add(
                Insight(
                    category = InsightCategory.Nutrition,
                    severity = InsightSeverity.Info,
                    title = "Skipped Breakfast",
                    message = "You haven't logged any breakfast yet. A morning meal helps stabilize blood sugar and energy levels.",
                    actionable = true
                )
            )
        }

        val afterEight = todayEntries.count {
            val hour = java.util.Calendar.getInstance().apply { timeInMillis = it.timestamp }
                .get(java.util.Calendar.HOUR_OF_DAY)
            hour >= 20
        }
        if (afterEight >= 1) {
            insights.add(
                Insight(
                    category = InsightCategory.Nutrition,
                    severity = InsightSeverity.Notice,
                    title = "Late Night Eating",
                    message = "Eating after 8 PM can affect sleep quality. Try to finish meals 2-3 hours before bedtime.",
                    actionable = true
                )
            )
        }

        if (mealCount <= 1 && totalCalories > 0) {
            insights.add(
                Insight(
                    category = InsightCategory.Nutrition,
                    severity = InsightSeverity.Info,
                    title = "Small Meal Count",
                    message = "You've only had $mealCount meal type(s). Spreading meals throughout the day can help maintain steady energy.",
                    actionable = false
                )
            )
        }

        val avgCaloriePerMeal = if (mealCount > 0) totalCalories / mealCount else 0.0
        if (avgCaloriePerMeal > 800) {
            insights.add(
                Insight(
                    category = InsightCategory.Nutrition,
                    severity = InsightSeverity.Notice,
                    title = "Large Portions",
                    message = "Your average meal is $avgCaloriePerMeal calories. Try smaller, more frequent meals for better energy management.",
                    actionable = true
                )
            )
        }

        return insights
    }

    private fun isToday(timestamp: Long): Boolean {
        val today = java.time.LocalDate.now()
        val date = java.time.Instant.ofEpochMilli(timestamp)
            .atZone(java.time.ZoneId.systemDefault())
            .toLocalDate()
        return date == today
    }
}
