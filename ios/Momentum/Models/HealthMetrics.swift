import Foundation

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return max(range.lowerBound, min(range.upperBound, self))
    }
}

struct DailyMetrics: Codable, Identifiable {
    let id: UUID
    let date: Date
    var sleepHours: Double
    var sleepQuality: SleepQuality
    var steps: Int
    var heartRateAvg: Double
    var heartRateVariability: Double
    var screenTimeMinutes: Double
    var focusScore: Int
    var energyLevel: EnergyLevel
    var stressLevel: StressLevel
    var calendarEventCount: Int
    var calendarIntensity: CalendarIntensity
    init(id: UUID = UUID(), date: Date = Date(), sleepHours: Double = 0, sleepQuality: SleepQuality = .average, steps: Int = 0, heartRateAvg: Double = 0, heartRateVariability: Double = 0, screenTimeMinutes: Double = 0, focusScore: Int = 50, energyLevel: EnergyLevel = .moderate, stressLevel: StressLevel = .moderate, calendarEventCount: Int = 0, calendarIntensity: CalendarIntensity = .low) {
        self.id = id; self.date = date; self.sleepHours = sleepHours; self.sleepQuality = sleepQuality; self.steps = steps; self.heartRateAvg = heartRateAvg; self.heartRateVariability = heartRateVariability; self.screenTimeMinutes = screenTimeMinutes; self.focusScore = focusScore; self.energyLevel = energyLevel; self.stressLevel = stressLevel; self.calendarEventCount = calendarEventCount; self.calendarIntensity = calendarIntensity
    }
}

enum SleepQuality: String, Codable, CaseIterable {
    case poor = "Poor"; case fair = "Fair"; case average = "Average"; case good = "Good"; case excellent = "Excellent"
    var score: Int {
        switch self {
        case .poor: return 20; case .fair: return 40; case .average: return 50; case .good: return 70; case .excellent: return 90
        }
    }
}

enum EnergyLevel: String, Codable, CaseIterable {
    case veryLow = "Very Low"; case low = "Low"; case moderate = "Moderate"; case high = "High"; case veryHigh = "Very High"
    static func from(rawScore: Int) -> EnergyLevel {
        let clamped = max(0, min(4, rawScore)); return EnergyLevel.allCases[clamped]
    }
}

enum StressLevel: String, Codable, CaseIterable {
    case low = "Low"; case moderate = "Moderate"; case high = "High"; case veryHigh = "Very High"
    static func from(rawScore: Int) -> StressLevel {
        let clamped = max(0, min(3, rawScore)); return StressLevel.allCases[clamped]
    }
}

enum CalendarIntensity: String, Codable, CaseIterable {
    case low = "Low"; case medium = "Medium"; case high = "High"; case overwhelming = "Overwhelming"
}
