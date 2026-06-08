import Foundation

actor AIPersonaEngine {
    static let shared = AIPersonaEngine()
    
    struct PersonaPreferences: Codable {
        var preferredActionCategories: [String] = ["breathing", "movement", "focus"]
        var energySensitivity: Double = 0.5
        var stressThreshold: Double = 0.6
        var coachTone: CoachTone = .encouraging
        var focusTimePreference: FocusTimePreference = .morning
        var notificationQuietHours: Bool = true
        var weeklyReviewDay: Int = 1
        var learningStyle: LearningStyle = .visual
        
        enum CoachTone: String, Codable { case encouraging = "Encouraging"; case direct = "Direct"; case scientific = "Scientific" }
        enum FocusTimePreference: String, Codable { case morning = "Morning"; case afternoon = "Afternoon"; case evening = "Evening" }
        enum LearningStyle: String, Codable { case visual = "Visual"; case reading = "Reading"; case interactive = "Interactive" }
    }
    
    var preferences: PersonaPreferences {
        get async { _preferences }
    }
    
    private var _preferences: PersonaPreferences {
        didSet { save() }
    }
    private let defaults = UserDefaults.standard
    private let key = "momentum_persona"
    
    init() {
        if let data = defaults.data(forKey: key),
           let prefs = try? JSONDecoder().decode(PersonaPreferences.self, from: data) {
            _preferences = prefs
        } else {
            _preferences = PersonaPreferences()
        }
    }
    
    func updatePreferences(_ update: (inout PersonaPreferences) -> Void) {
        var prefs = _preferences
        update(&prefs)
        _preferences = prefs
    }
    
    func adaptToUserAction(actionId: String, wasEffective: Bool) {
        updatePreferences { prefs in
            if wasEffective {
                let category = actionId.split(separator: " ").first.map(String.init) ?? ""
                if !prefs.preferredActionCategories.contains(where: { $0.lowercased() == category.lowercased() }) {
                    prefs.preferredActionCategories.insert(category.lowercased(), at: 0)
                    if prefs.preferredActionCategories.count > 5 {
                        prefs.preferredActionCategories = Array(prefs.preferredActionCategories.prefix(5))
                    }
                }
            }
        }
    }
    
    func coachGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    func coachMessage(for insight: Insight) -> String {
        switch _preferences.coachTone {
        case .encouraging:
            return "I noticed something important: \(insight.title). \(insight.description) Let's try \(insight.recommendation.title) together — it'll take just \(Int(insight.recommendation.duration / 60)) minutes."
        case .direct:
            return "Insight: \(insight.title). \(insight.description). Recommendation: \(insight.recommendation.title) (\(Int(insight.recommendation.duration / 60)) min)."
        case .scientific:
            let scienceNote = insight.recommendation.scienceNote ?? ""
            return "Data point: \(insight.title). \(insight.description). \(scienceNote). Suggested intervention: \(insight.recommendation.title)."
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(_preferences) {
            defaults.set(data, forKey: key)
        }
    }
}
