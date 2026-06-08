import Foundation
import CoreML

actor LocalMLService {
    static let shared = LocalMLService()
    
    private var model: MLModel?
    private var modelLoaded = false
    
    private let featureStore = FeatureStore.shared
    private let predictiveEngine = PredictiveEngine.shared
    private let patternRecognizer = PatternRecognizer.shared
    private let adaptiveRecommender = AdaptiveRecommender.shared
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        guard let modelURL = Bundle.main.url(forResource: "MomentumPredictor", withExtension: "mlmodel") ?? Bundle.main.url(forResource: "MomentumPredictor", withExtension: "mlmodelc") else {
            print("Momentum: MomentumPredictor.mlmodel not found, using Bayesian fallback")
            modelLoaded = false
            return
        }
        do {
            model = try MLModel(contentsOf: modelURL)
            modelLoaded = true
        } catch {
            print("Momentum: Failed to load CoreML model: \(error)")
            modelLoaded = false
        }
    }
    
    func neuralPredict(features: FeatureVector) async -> Prediction? {
        guard modelLoaded, let model = model else { return nil }
        do {
            let inputFeatures = try MLMultiArray(shape: [1, 15], dataType: .double)
            let values: [Double] = [
                Double(features.dayOfWeek), Double(features.hour), features.sleepHours,
                Double(features.sleepQualityScore), Double(features.steps), features.heartRateAvg,
                features.heartRateVariability, features.screenTimeMinutes, Double(features.calendarIntensity),
                Double(features.previousDayEnergy), Double(features.previousDayStress),
                Double(features.previousDayFocus), features.weekToDateSleepAvg,
                Double(features.weekToDateStepsAvg), Double(features.monthToDateFocusAvg)
            ]
            for (i, val) in values.enumerated() {
                inputFeatures[i] = NSNumber(value: val)
            }
            let provider = try MLDictionaryFeatureProvider(dictionary: ["features": inputFeatures])
            let output = try model.prediction(from: provider)
            let energyProb = output.featureValue(for: "energy")?.multiArrayValue?[0].doubleValue ?? 0.5
            let focusVal = output.featureValue(for: "focus")?.multiArrayValue?[0].intValue ?? 50
            let stressProb = output.featureValue(for: "stress")?.multiArrayValue?[0].doubleValue ?? 0.5
            let confidenceVal = output.featureValue(for: "confidence")?.multiArrayValue?[0].doubleValue ?? 0.7
            
            let predictedEnergy: EnergyLevel = {
                if energyProb < 0.2 { return .veryLow }
                if energyProb < 0.4 { return .low }
                if energyProb < 0.6 { return .moderate }
                if energyProb < 0.8 { return .high }
                return .veryHigh
            }()
            let predictedStress: StressLevel = {
                if stressProb < 0.25 { return .low }
                if stressProb < 0.5 { return .moderate }
                if stressProb < 0.75 { return .high }
                return .veryHigh
            }()
            
            return Prediction(
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                predictedEnergy: predictedEnergy,
                predictedFocus: max(0, min(100, focusVal)),
                predictedStress: predictedStress,
                confidence: min(0.99, max(0.5, confidenceVal)),
                keyDriver: "neural_ensemble"
            )
        } catch {
            print("Momentum: Neural prediction failed: \(error)")
            return nil
        }
    }
    
    func generateAIAugmentedInsight(from metrics: DailyMetrics) async -> (insight: String, confidence: Double) {
        let bayesianPrediction = predictiveEngine.predictTomorrow()
        let neuralPrediction: Prediction? = await {
            if let vector = featureStore.buildVector(for: metrics.date) {
                return await neuralPredict(features: vector)
            }
            return nil
        }()
        
        var blendedEnergy: EnergyLevel
        var blendedFocus: Int
        var blendedStress: StressLevel
        var confidence: Double
        
        let neuralWeight = 0.6
        let bayesianWeight = 1.0 - neuralWeight
        
        if let neural = neuralPrediction {
            let neuralEnergyVal = EnergyLevelToInt(neural.predictedEnergy)
            let bayesianEnergyVal = EnergyLevelToInt(bayesianPrediction.predictedEnergy)
            let blendedEnergyVal = Int(round(Double(neuralEnergyVal) * neuralWeight + Double(bayesianEnergyVal) * bayesianWeight))
            blendedEnergy = EnergyLevel.from(rawScore: blendedEnergyVal.clamped(to: 0...4))
            
            blendedFocus = Int(round(Double(neural.predictedFocus) * neuralWeight + Double(bayesianPrediction.predictedFocus) * bayesianWeight))
            
            let neuralStressVal = StressLevelToInt(neural.predictedStress)
            let bayesianStressVal = StressLevelToInt(bayesianPrediction.predictedStress)
            let blendedStressVal = Int(round(Double(neuralStressVal) * neuralWeight + Double(bayesianStressVal) * bayesianWeight))
            blendedStress = StressLevel.from(rawScore: blendedStressVal.clamped(to: 0...3))
            
            let agreement = 1.0 - abs(Double(neuralEnergyVal - bayesianEnergyVal)) / 4.0
            let baseConfidence = (neural.confidence + bayesianPrediction.confidence) / 2.0
            confidence = min(0.99, baseConfidence + agreement * 0.1)
        } else {
            blendedEnergy = bayesianPrediction.predictedEnergy
            blendedFocus = bayesianPrediction.predictedFocus
            blendedStress = bayesianPrediction.predictedStress
            confidence = bayesianPrediction.confidence * 0.85
        }
        
        let patterns = await patternRecognizer.detectPatterns()
        var insightText: String
        
        if let keyPattern = patterns.first(where: { $0.strength > 0.6 }) {
            insightText = keyPattern.description
        } else {
            switch blendedEnergy {
            case .veryLow, .low:
                insightText = "Tomorrow looks like a low-energy day. Focus on recovery and essentials."
            case .moderate:
                insightText = "Tomorrow should be a balanced day — moderate energy expected."
            case .high, .veryHigh:
                insightText = "Tomorrow looks energetic! Great for tackling important work."
            }
        }
        
        if blendedFocus < 40 {
            insightText += " Focus may be challenging — plan for deep work in the morning."
        }
        if blendedStress == .high || blendedStress == .veryHigh {
            insightText += " Watch for elevated stress — build in recovery breaks."
        }
        
        let recommendedAction = adaptiveRecommender.personalizedAction(
            for: bayesianPrediction.keyDriver,
            basedOn: await featureStore.getProfile()
        )
        insightText += " Try: \(recommendedAction.title)."
        
        return (insightText, confidence)
    }
    
    func generateEnergyForecast() async -> [(hour: Int, level: EnergyLevel)] {
        let hours = [8, 10, 12, 14, 16, 18, 20]
        var forecast: [(Int, EnergyLevel)] = []
        for hour in hours {
            let level = await predictiveEngine.predictEnergyAt(hour: hour)
            forecast.append((hour, level))
        }
        return forecast
    }
    
    func todaysIntegratedScore() async -> (overall: Int, sleep: Int, energy: Int, focus: Int, stress: Int, recovery: Int) {
        let metrics = await featureStore.todaysMetrics()
        let sleepScore = metrics.sleepQuality.score
        let energyScore = EnergyLevelToInt(metrics.energyLevel) * 25
        let focusScore = metrics.focusScore
        let stressScore = max(0, 100 - StressLevelToInt(metrics.stressLevel) * 33)
        let recoveryScore: Int = {
            var score = 50
            if metrics.sleepHours >= 7 { score += 15 }
            if metrics.heartRateVariability > 40 { score += 15 }
            if metrics.stressLevel == .low || metrics.stressLevel == .moderate { score += 10 }
            if metrics.screenTimeMinutes < 240 { score += 10 }
            return min(100, score)
        }()
        let overall = Int(round(Double(sleepScore + energyScore + focusScore + stressScore + recoveryScore) / 5.0))
        return (overall, sleepScore, energyScore, focusScore, stressScore, recoveryScore)
    }
    
    func analyzeFoodPatterns(entries: [FoodEntry]) -> String {
        guard entries.count >= 3 else { return "Log more meals to discover patterns." }
        let mealTypes = Dictionary(grouping: entries, by: \.mealType)
        let mostLogged = mealTypes.max(by: { $0.value.count < $1.value.count })?.key ?? .breakfast
        let avgCalories = entries.map(\.macros.calories).reduce(0, +) / entries.count
        let avgProtein = entries.map(\.macros.protein).reduce(0, +) / Double(entries.count)
        if avgProtein < 15 {
            return "You tend to log \(mostLogged.rawValue)s most often, averaging \(avgCalories) cal. Protein is low (\(Int(avgProtein))g avg)."
        }
        return "You tend to log \(mostLogged.rawValue)s most often, averaging \(avgCalories) cal with \(Int(avgProtein))g protein."
    }
    
    private func EnergyLevelToInt(_ level: EnergyLevel) -> Int {
        switch level {
        case .veryLow: return 0
        case .low: return 1
        case .moderate: return 2
        case .high: return 3
        case .veryHigh: return 4
        }
    }
    
    private func StressLevelToInt(_ level: StressLevel) -> Int {
        switch level {
        case .low: return 0
        case .moderate: return 1
        case .high: return 2
        case .veryHigh: return 3
        }
    }
}
