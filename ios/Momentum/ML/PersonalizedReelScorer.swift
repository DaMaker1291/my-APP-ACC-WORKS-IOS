import Foundation

actor PersonalizedReelScorer {
    static let shared = PersonalizedReelScorer()
    
    struct ScoredReel: Identifiable {
        let id: UUID
        let reel: ExerciseReel
        let score: Double
        let reason: String
    }
    
    private let defaultReels: [ExerciseReel] = [
        ExerciseReel(id: UUID(), title: "Morning Stretch", description: "Wake up your body with gentle full-body stretches", duration: 300, category: .mobility, iconName: "figure.flexibility", colorHex: "#2DD4BF", scienceNote: "Morning stretching reduces injury risk by 30%"),
        ExerciseReel(id: UUID(), title: "Core Strength", description: "Build a strong foundation with plank variations", duration: 420, category: .strength, iconName: "figure.core.training", colorHex: "#5E5CE6", scienceNote: "Core strength improves posture and reduces back pain"),
        ExerciseReel(id: UUID(), title: "Walking Flow", description: "Low-impact cardio to boost mood and circulation", duration: 600, category: .cardio, iconName: "figure.walk", colorHex: "#30D158", scienceNote: "Walking 15 min reduces cortisol by 25%"),
        ExerciseReel(id: UUID(), title: "Mindful Breathing", description: "Calm your mind with deep breathing exercises", duration: 300, category: .mindfulness, iconName: "wind", colorHex: "#FFD60A", scienceNote: "Deep breathing activates the parasympathetic nervous system"),
        ExerciseReel(id: UUID(), title: "Recovery Flow", description: "Gentle movements to aid muscle recovery", duration: 480, category: .recovery, iconName: "heart.circle", colorHex: "#FF453A", scienceNote: "Active recovery reduces lactic acid buildup by 40%"),
        ExerciseReel(id: UUID(), title: "Desk Mobility", description: "Release tension from sitting with mobility drills", duration: 240, category: .mobility, iconName: "figure.seated.side", colorHex: "#FFD60A", scienceNote: "Taking movement breaks every hour boosts focus by 20%"),
    ]
    
    func scoreReels(profile: UserProfile, metrics: DailyMetrics) -> [ScoredReel] {
        var scored: [ScoredReel] = []
        let effectiveActionCategories = Set(profile.effectiveActions.keys.compactMap { key -> String? in
            return key.split(separator: " ").first.map(String.init)
        })
        
        for reel in defaultReels {
            var score = 0.5
            var reasons: [String] = []
            
            // Match against effective action categories
            for cat in effectiveActionCategories {
                if reel.category.rawValue.lowercased().contains(cat.lowercased()) ||
                    cat.lowercased().contains(reel.category.rawValue.lowercased()) {
                    score += 0.15
                    reasons.append("Matches your effective habits")
                }
            }
            
            // Adapt to current state
            if metrics.stressLevel == .high || metrics.stressLevel == .veryHigh {
                if reel.category == .mindfulness || reel.category == .recovery {
                    score += 0.2
                    reasons.append("Stress-lowering recommendation")
                }
            }
            if metrics.energyLevel == .low || metrics.energyLevel == .veryLow {
                if reel.category == .recovery || reel.category == .mobility {
                    score += 0.15
                    reasons.append("Low-energy friendly")
                }
            }
            if metrics.energyLevel == .high || metrics.energyLevel == .veryHigh {
                if reel.category == .cardio || reel.category == .strength {
                    score += 0.15
                    reasons.append("High-energy opportunity")
                }
            }
            if metrics.focusScore < 40 {
                if reel.category == .mindfulness {
                    score += 0.15
                    reasons.append("Focus improvement")
                }
            }
            if metrics.sleepHours < 6 {
                if reel.category == .recovery || reel.category == .mindfulness {
                    score += 0.1
                    reasons.append("Sleep recovery support")
                }
            }
            
            score = min(1.0, score)
            let reason = reasons.first ?? "Personalized for you"
            scored.append(ScoredReel(id: reel.id, reel: reel, score: score, reason: reason))
        }
        
        return scored.sorted { $0.score > $1.score }
    }
    
    func allReels() -> [ExerciseReel] {
        return defaultReels
    }
    
    func reelForCategory(_ category: ExerciseReel.ReelCategory) -> ExerciseReel? {
        return defaultReels.first { $0.category == category }
    }
}
