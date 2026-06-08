package com.momentum.app.models

import java.util.UUID

data class CoachMessage(
    val id: String = UUID.randomUUID().toString(),
    val type: MessageType,
    val title: String,
    val body: String,
    val actionTitle: String? = null,
    val actionType: String? = null,
    val timestamp: Long = System.currentTimeMillis(),
    val priority: Int = 0
)

enum class MessageType {
    MorningBriefing, EveningReview, Alert, Suggestion, Achievement, CheckIn
}

data class Challenge(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String,
    val durationDays: Int,
    val category: MicroActionCategory,
    val reward: String,
    val progress: Int = 0,
    val completed: Boolean = false
)

data class JournalEntry(
    val id: String = UUID.randomUUID().toString(),
    val content: String,
    val mood: Int = 5,
    val energyBefore: EnergyLevel = EnergyLevel.Moderate,
    val energyAfter: EnergyLevel = EnergyLevel.Moderate,
    val reflectionQuestions: List<Pair<String, String>> = emptyList(),
    val timestamp: Long = System.currentTimeMillis()
)

data class FocusSession(
    val id: String = UUID.randomUUID().toString(),
    val durationMinutes: Int = 25,
    val completedMinutes: Int = 0,
    val interrupted: Boolean = false,
    val focusScoreAfter: Int? = null,
    val timestamp: Long = System.currentTimeMillis()
)

data class PersonalizedContent(
    val id: String = UUID.randomUUID().toString(),
    val type: ContentType,
    val title: String,
    val subtitle: String,
    val body: String,
    val actionLabel: String? = null
)

enum class ContentType {
    Article, Tip, Exercise, Recipe, Meditation, Challenge
}
