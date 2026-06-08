package com.momentum.app.ml

import android.content.Context
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.FeatureVector
import com.momentum.app.models.Insight
import com.momentum.app.models.InsightCategory
import com.momentum.app.models.InsightSeverity
import com.momentum.app.services.DataService

class LocalMLService(private val context: Context) {

    private val tfliteModel: TFLiteModel by lazy { TFLiteModel(context) }
    private val featureStore: FeatureStore by lazy { FeatureStore(context) }
    private val predictiveEngine: PredictiveEngine by lazy { PredictiveEngine(featureStore) }
    private val patternRecognizer: PatternRecognizer by lazy { PatternRecognizer(featureStore) }
    private val adaptiveRecommender: AdaptiveRecommender by lazy { AdaptiveRecommender(context, featureStore) }

    fun neuralPredict(features: FeatureVector): FloatArray? {
        return tfliteModel.predict(features)
    }

    fun predictTomorrow(metrics: DailyMetrics): com.momentum.app.models.Prediction {
        return predictiveEngine.predictTomorrow(metrics)
    }

    fun detectPatterns(): List<com.momentum.app.models.Pattern> {
        return patternRecognizer.detectAll(featureStore.loadMetrics())
    }

    fun generateAIAugmentedInsight(
        metrics: DailyMetrics,
        baseInsight: Insight
    ): Insight {
        val neuralFeatures = featureStore.buildVector(metrics)
        val neuralOutput = neuralPredict(neuralFeatures)

        if (neuralOutput != null && neuralOutput.size >= 3) {
            val predictedEnergyScore = (neuralOutput[0] * 100).toInt().coerceIn(0, 100)
            val predictedFocusDelta = ((neuralOutput[1] - 0.5) * 20).toInt()
            val predictedStressRisk = neuralOutput[2]

            val augmentedMessage = buildAugmentedMessage(
                baseInsight, predictedEnergyScore, predictedFocusDelta, predictedStressRisk
            )

            return baseInsight.copy(
                message = augmentedMessage,
                severity = if (predictedStressRisk > 0.7 && baseInsight.severity.ordinal < InsightSeverity.Critical.ordinal) {
                    InsightSeverity.Critical
                } else if (predictedStressRisk > 0.5 && baseInsight.severity.ordinal < InsightSeverity.Warning.ordinal) {
                    InsightSeverity.Warning
                } else {
                    baseInsight.severity
                }
            )
        }

        return baseInsight
    }

    private fun buildAugmentedMessage(
        base: Insight,
        energyScore: Int,
        focusDelta: Int,
        stressRisk: Double
    ): String {
        val stressNote = when {
            stressRisk > 0.7 -> " ⚠️ High stress risk predicted for tomorrow."
            stressRisk > 0.5 -> " Moderate stress expected tomorrow."
            else -> " Low stress expected tomorrow."
        }

        val focusNote = when {
            focusDelta > 5 -> " Focus predicted to improve by $focusDelta points."
            focusDelta < -5 -> " Focus may drop by ${-focusDelta} points."
            else -> " Focus levels are stable."
        }

        return "${base.message}$stressNote$focusNote"
    }

    fun getRecommendation(insight: Insight): com.momentum.app.models.MicroAction? {
        return adaptiveRecommender.selectAction(insight)
    }

    fun onActionResult(actionId: String, effectiveness: Double) {
        adaptiveRecommender.recordEffectiveness(actionId, effectiveness)
    }

    fun ingestMetrics(metrics: DailyMetrics) {
        featureStore.ingest(metrics)
    }

    fun loadRecentMetrics(): List<DailyMetrics> {
        return featureStore.loadMetrics()
    }

    fun getFeatureStore(): FeatureStore = featureStore
}
