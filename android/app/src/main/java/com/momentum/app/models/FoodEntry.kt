package com.momentum.app.models

import java.util.UUID

data class FoodEntry(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val calories: Double,
    val protein: Double = 0.0,
    val carbs: Double = 0.0,
    val fat: Double = 0.0,
    val mealType: MealType = MealType.Snack,
    val source: FoodSource = FoodSource.Manual,
    val timestamp: Long = System.currentTimeMillis(),
    val imageUri: String? = null,
    val barcode: String? = null
)

data class MacroSummary(
    val calories: Double = 0.0,
    val protein: Double = 0.0,
    val carbs: Double = 0.0,
    val fat: Double = 0.0
)

data class BarcodeFoodItem(
    val barcode: String,
    val name: String,
    val calories: Double,
    val protein: Double = 0.0,
    val carbs: Double = 0.0,
    val fat: Double = 0.0
)

data class AIFoodRecognition(
    val name: String,
    val estimatedCalories: Double,
    val estimatedProtein: Double,
    val estimatedCarbs: Double,
    val estimatedFat: Double,
    val confidence: Double,
    val alternativeNames: List<String> = emptyList()
)

enum class MealType(val label: String) {
    Breakfast("Breakfast"),
    Lunch("Lunch"),
    Dinner("Dinner"),
    Snack("Snack")
}

enum class FoodSource(val label: String) {
    Camera("Camera"),
    Barcode("Barcode"),
    TextSearch("Text Search"),
    Manual("Manual"),
    AI("AI")
}
