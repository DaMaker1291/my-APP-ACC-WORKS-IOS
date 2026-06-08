import Foundation

struct Prediction: Codable {
    let date: Date; let predictedEnergy: EnergyLevel; let predictedFocus: Int; let predictedStress: StressLevel; let confidence: Double; let keyDriver: String
}

struct Pattern: Codable, Identifiable {
    let id: UUID; let type: PatternType; let description: String; let frequency: Double; let strength: Double; let actionable: Bool; let suggestedAction: MicroAction?
    enum PatternType: String, Codable { case weekly = "Weekly"; case daily = "Daily"; case trigger = "Trigger"; case correlation = "Correlation"; case anomaly = "Anomaly" }
}

struct UserProfile: Codable {
    var baselineSleep: Double = 7.0; var baselineSteps: Int = 5000; var baselineHRV: Double = 40.0; var effectiveActions: [String: Double] = [:]; var triggerPatterns: [String: Double] = [:]; var weeklyPattern: [Int: Double] = [:]; var learningVersion: Int = 1; var daysTracked: Int = 0
}

struct FeatureVector: Codable {
    let dayOfWeek: Int; let hour: Int; let sleepHours: Double; let sleepQualityScore: Int; let steps: Int; let heartRateAvg: Double; let heartRateVariability: Double; let screenTimeMinutes: Double; let calendarIntensity: Int; let previousDayEnergy: Int; let previousDayStress: Int; let previousDayFocus: Int; let weekToDateSleepAvg: Double; let weekToDateStepsAvg: Int; let monthToDateFocusAvg: Int
}
