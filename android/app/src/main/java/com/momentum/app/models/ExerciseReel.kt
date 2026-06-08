package com.momentum.app.models

import java.util.UUID

data class ExerciseReel(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String,
    val duration: String,
    val category: ReelCategory,
    val iconName: String = "figure.run",
    val colorHex: String = "#4FC3F7",
    val scienceNote: String? = null
)

enum class ReelCategory(val label: String) {
    Quick("Quick"),
    Strength("Strength"),
    Cardio("Cardio"),
    Yoga("Yoga"),
    Stretch("Stretch"),
    HIIT("HIIT"),
    Walk("Walk"),
    Mindful("Mindful")
}
