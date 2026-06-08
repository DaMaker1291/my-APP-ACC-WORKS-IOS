import Foundation

actor PredictiveEngine {
    static let shared = PredictiveEngine()
    
    private var featureStore: FeatureStore { .shared }
    
    func predictTomorrow() -> Prediction {
        let history = featureStore.getHistory()
        let profile = featureStore.getProfile()
        let today = history.last ?? DailyMetrics()
        
        // Energy prediction using weighted moving average
        let recentEnergyValues = history.suffix(7).map { EnergyLevelToInt($0.energyLevel) }
        let weights: [Double] = [0.35, 0.25, 0.18, 0.12, 0.07, 0.03]
        let weightedEnergy = zip(recentEnergyValues, weights).reduce(0.0) { $0 + Double($1.0) * $1.1 }
        let reweighted = recentEnergyValues.count < 4 ? Double(recentEnergyValues.last ?? 2) : weightedEnergy
        
        // Sleep correction
        let sleepCorrection: Double = {
            if today.sleepHours < 5 { return -0.8 }
            if today.sleepHours < 6 { return -0.4 }
            if today.sleepHours > 9 { return 0.3 }
            return 0
        }()
        
        // Calendar intensity correction
        let calendarCorrection: Double = {
            switch today.calendarIntensity {
            case .overwhelming: return -0.6
            case .high: return -0.3
            case .medium: return -0.1
            case .low: return 0.1
            }
        }()
        
        let rawEnergy = reweighted + sleepCorrection + calendarCorrection
        let clampedEnergy = max(0, min(4, round(rawEnergy)))
        let predictedEnergy = EnergyLevel.from(rawScore: Int(clampedEnergy))
        
        // Focus prediction
        let recentFocus = history.suffix(7).map(\.focusScore)
        let weightedFocus = zip(recentFocus, weights).reduce(0.0) { $0 + Double($1.0) * $1.1 }
        var predictedFocus = Int(weightedFocus)
        if today.sleepHours < 6 { predictedFocus -= 10 }
        if today.calendarIntensity == .overwhelming { predictedFocus -= 5 }
        predictedFocus = max(0, min(100, predictedFocus))
        
        // Stress prediction
        let recentStress = history.suffix(7).map { StressLevelToInt($0.stressLevel) }
        let weightedStress = zip(recentStress, weights).reduce(0.0) { $0 + Double($1.0) * $1.1 }
        let rawStress = weightedStress - sleepCorrection + calendarCorrection * 0.5
        let clampedStress = max(0, min(3, round(rawStress)))
        let predictedStress = StressLevel.from(rawScore: Int(clampedStress))
        
        // Confidence based on data volume
        let daysWithData = min(history.count, 30)
        let confidence = 0.5 + Double(daysWithData) * 0.015
        
        // Key driver identification
        let keyDriver: String = {
            if today.sleepHours < 6 { return "sleep" }
            if today.calendarIntensity == .overwhelming || today.calendarIntensity == .high { return "calendar" }
            if today.steps < 2000 { return "movement" }
            return "sleep"
        }()
        
        return Prediction(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            predictedEnergy: predictedEnergy,
            predictedFocus: predictedFocus,
            predictedStress: predictedStress,
            confidence: min(0.95, confidence),
            keyDriver: keyDriver
        )
    }
    
    func predictEnergyAt(hour: Int) -> EnergyLevel {
        let history = featureStore.getHistory()
        let today = history.last ?? DailyMetrics()
        
        // Circadian energy curve
        let circadianBase: Double = {
            switch hour {
            case 6..<9: return 2.5 // Morning rise
            case 9..<12: return 3.5 // Peak morning
            case 12..<14: return 2.0 // Post-lunch dip
            case 14..<17: return 3.0 // Afternoon rebound
            case 17..<20: return 2.5 // Evening decline
            case 20..<23: return 1.5 // Wind down
            case 23..<24, 0..<6: return 0.5 // Sleep period
            default: return 2.0
            }
        }()
        
        var adjusted = circadianBase
        
        // Sleep quality adjustment
        if today.sleepHours < 6 { adjusted -= 0.8 }
        if today.sleepHours < 5 { adjusted -= 0.5 }
        
        // HRV adjustment
        if today.heartRateVariability > 50 { adjusted += 0.3 }
        if today.heartRateVariability < 25 && today.heartRateVariability > 0 { adjusted -= 0.3 }
        
        // Calendar adjustment
        switch today.calendarIntensity {
        case .overwhelming: adjusted -= 0.6
        case .high: adjusted -= 0.3
        default: break
        }
        
        let clamped = max(0, min(4, round(adjusted)))
        return EnergyLevel.from(rawScore: Int(clamped))
    }
    
    func probabilityOf(event: String, given condition: String) -> Double {
        let history = featureStore.getHistory()
        guard history.count >= 3 else { return 0.5 }
        
        var conditionCount = 0
        var eventCount = 0
        
        for metrics in history {
            let matchesCondition: Bool = {
                switch condition {
                case "low_sleep": return metrics.sleepHours < 6
                case "high_stress": return metrics.stressLevel == .high || metrics.stressLevel == .veryHigh
                case "high_calendar": return metrics.calendarIntensity == .high || metrics.calendarIntensity == .overwhelming
                case "low_steps": return metrics.steps < 3000
                case "high_focus": return metrics.focusScore > 70
                default: return false
                }
            }()
            let matchesEvent: Bool = {
                switch event {
                case "low_energy": return metrics.energyLevel == .low || metrics.energyLevel == .veryLow
                case "high_stress": return metrics.stressLevel == .high || metrics.stressLevel == .veryHigh
                case "low_focus": return metrics.focusScore < 40
                case "good_sleep": return metrics.sleepHours >= 7
                default: return false
                }
            }()
            if matchesCondition { conditionCount += 1 }
            if matchesCondition && matchesEvent { eventCount += 1 }
        }
        
        guard conditionCount > 0 else { return 0.5 }
        return Double(eventCount) / Double(conditionCount)
    }
    
    func tomorrowPredictionWithExplanation() -> (prediction: Prediction, explanation: String) {
        let prediction = predictTomorrow()
        var explanation = ""
        let history = featureStore.getHistory()
        let today = history.last ?? DailyMetrics()
        
        if today.sleepHours < 6 {
            explanation = "Low sleep (\(String(format: "%.1f", today.sleepHours))h) is the main driver. Your energy tomorrow may be reduced."
        } else if today.calendarIntensity == .overwhelming || today.calendarIntensity == .high {
            explanation = "Heavy calendar load (\(today.calendarEventCount) events) is the key factor. Your energy may be drained."
        } else if today.steps < 2000 {
            explanation = "Low movement today may impact tomorrow's energy."
        } else {
            explanation = "Based on recent patterns, tomorrow looks consistent with your baseline."
        }
        
        return (prediction, explanation)
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
