package com.momentum.app.ml

import android.content.Context
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.Insight
import com.momentum.app.models.InsightCategory
import com.momentum.app.models.MicroAction
import com.momentum.app.models.MicroActionCategory

class AdaptiveRecommender(
    private val context: Context,
    private val featureStore: FeatureStore
) {

    private val microActions = listOf(
        MicroAction(
            id = "breath_4_7_8",
            title = "4-7-8 Breathing",
            description = "Inhale 4s, hold 7s, exhale 8s. Calms nervous system.",
            category = MicroActionCategory.Breathing,
            durationMinutes = 4,
            energyCost = EnergyLevel.Low,
            iconName = "wind"
        ),
        MicroAction(
            id = "walk_5min",
            title = "5 Minute Walk",
            description = "Quick walk to reset your energy and focus.",
            category = MicroActionCategory.Movement,
            durationMinutes = 5,
            energyCost = EnergyLevel.Moderate,
            iconName = "figure.walk"
        ),
        MicroAction(
            id = "stretch_desk",
            title = "Desk Stretch",
            description = "Gentle stretches to release tension from sitting.",
            category = MicroActionCategory.Movement,
            durationMinutes = 5,
            energyCost = EnergyLevel.Low,
            iconName = "figure.flexibility"
        ),
        MicroAction(
            id = "hydrate",
            title = "Drink Water",
            description = "Drink a glass of water. Hydration boosts cognition.",
            category = MicroActionCategory.Nutrition,
            durationMinutes = 2,
            energyCost = EnergyLevel.Low,
            iconName = "drop"
        ),
        MicroAction(
            id = "focus_block",
            title = "25-min Focus Block",
            description = "Set a timer and focus on one task for 25 minutes.",
            category = MicroActionCategory.Focus,
            durationMinutes = 25,
            energyCost = EnergyLevel.High,
            iconName = "timer"
        ),
        MicroAction(
            id = "gratitude",
            title = "3 Things",
            description = "Write down 3 things you're grateful for right now.",
            category = MicroActionCategory.Social,
            durationMinutes = 3,
            energyCost = EnergyLevel.Low,
            iconName = "heart"
        ),
        MicroAction(
            id = "declutter",
            title = "Desk Tidy",
            description = "Spend 2 minutes tidying your immediate workspace.",
            category = MicroActionCategory.Environment,
            durationMinutes = 2,
            energyCost = EnergyLevel.Low,
            iconName = "tray"
        )
    )

    fun selectAction(insight: Insight): MicroAction? {
        val effectiveness = featureStore.getActionEffectiveness()

        val candidates = microActions.filter { action ->
            when (insight.category) {
                InsightCategory.Sleep -> action.category == MicroActionCategory.Rest
                InsightCategory.Activity -> action.category == MicroActionCategory.Movement
                InsightCategory.Nutrition -> action.category == MicroActionCategory.Nutrition
                InsightCategory.Focus -> action.category == MicroActionCategory.Focus
                InsightCategory.Stress -> action.category == MicroActionCategory.Breathing || action.category == MicroActionCategory.Movement
                InsightCategory.Energy -> action.category == MicroActionCategory.Movement || action.category == MicroActionCategory.Nutrition
                InsightCategory.Calendar -> action.category == MicroActionCategory.Environment || action.category == MicroActionCategory.Breathing
                else -> true
            }
        }

        if (candidates.isEmpty()) return microActions.firstOrNull()

        return candidates.maxByOrNull { action ->
            val effective = effectiveness[action.id] ?: 0.5
            effective + (action.durationMinutes.toDouble() / 60.0) * 0.1
        }
    }

    fun recordEffectiveness(actionId: String, effectiveness: Double) {
        featureStore.recordActionResult(actionId, effectiveness)
    }

    fun getAllActions(): List<MicroAction> = microActions

    fun getTopActions(limit: Int = 3): List<MicroAction> {
        val effectiveness = featureStore.getActionEffectiveness()
        return microActions
            .sortedByDescending { effectiveness[it.id] ?: 0.5 }
            .take(limit)
    }
}
