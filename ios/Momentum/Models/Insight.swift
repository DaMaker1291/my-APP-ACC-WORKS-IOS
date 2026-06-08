import Foundation

struct Insight: Codable, Identifiable {
    let id: UUID; let date: Date; let title: String; let description: String; let category: InsightCategory; let severity: InsightSeverity; let recommendation: MicroAction; let correlation: Correlation?
    init(id: UUID = UUID(), date: Date = Date(), title: String, description: String, category: InsightCategory, severity: InsightSeverity, recommendation: MicroAction, correlation: Correlation? = nil) {
        self.id = id; self.date = date; self.title = title; self.description = description; self.category = category; self.severity = severity; self.recommendation = recommendation; self.correlation = correlation
    }
}

enum InsightCategory: String, Codable { case sleep = "Sleep"; case movement = "Movement"; case nutrition = "Nutrition"; case focus = "Focus"; case stress = "Stress"; case recovery = "Recovery"; case combined = "Combined" }
enum InsightSeverity: String, Codable { case info = "Info"; case warning = "Warning"; case critical = "Critical" }

struct MicroAction: Codable, Identifiable {
    let id: UUID; let title: String; let description: String; let duration: TimeInterval; let category: MicroActionCategory; let scienceNote: String?
    init(id: UUID = UUID(), title: String, description: String, duration: TimeInterval, category: MicroActionCategory, scienceNote: String? = nil) {
        self.id = id; self.title = title; self.description = description; self.duration = duration; self.category = category; self.scienceNote = scienceNote
    }
}

enum MicroActionCategory: String, Codable { case breathing = "Breathing"; case movement = "Movement"; case focus = "Focus"; case reset = "Reset"; case rest = "Rest"; case mindfulness = "Mindfulness" }

struct Correlation: Codable { let factorA: String; let factorB: String; let strength: Double; let description: String }

struct DayScore: Codable, Identifiable {
    let id: UUID; let date: Date; let overallScore: Int; let energyScore: Int; let focusScore: Int; let stressScore: Int; let sleepScore: Int; let recoveryScore: Int
    init(id: UUID = UUID(), date: Date = Date(), overallScore: Int = 0, energyScore: Int = 0, focusScore: Int = 0, stressScore: Int = 0, sleepScore: Int = 0, recoveryScore: Int = 0) {
        self.id = id; self.date = date; self.overallScore = overallScore; self.energyScore = energyScore; self.focusScore = focusScore; self.stressScore = stressScore; self.sleepScore = sleepScore; self.recoveryScore = recoveryScore
    }
}
