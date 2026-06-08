import Foundation

actor AdaptiveRecommender {
    static let shared = AdaptiveRecommender()
    
    private let microActions: [MicroAction] = [
        MicroAction(title: "Power Down", description: "Turn off screens 30 mins before bed", duration: 1800, category: .rest, scienceNote: "Blue light suppresses melatonin production by up to 50%"),
        MicroAction(title: "Gentle Walk", description: "Take a 10-minute walk outdoors", duration: 600, category: .movement, scienceNote: "Walking increases blood flow to the brain by 20%"),
        MicroAction(title: "Coherent Breathing", description: "Breathe at 5 breaths per minute", duration: 300, category: .breathing, scienceNote: "Box breathing activates the vagus nerve, lowering heart rate"),
        MicroAction(title: "Single Task Sprint", description: "Focus on one task for 25 minutes", duration: 1500, category: .focus, scienceNote: "Single-tasking reduces cortisol and increases output quality"),
        MicroAction(title: "Digital Reset", description: "No screens for 1 hour", duration: 3600, category: .reset, scienceNote: "Digital detox lowers anxiety and improves sleep quality"),
        MicroAction(title: "Buffer Block", description: "Schedule 15 min gap between meetings", duration: 900, category: .rest, scienceNote: "Transition buffers reduce cognitive switching costs by 40%"),
        MicroAction(title: "Gratitude Pause", description: "Write down 3 things you're grateful for", duration: 120, category: .mindfulness, scienceNote: "Gratitude journaling increases long-term well-being by 10%"),
    ]
    
    func personalizedAction(for signal: String, basedOn profile: UserProfile) -> MicroAction {
        let effectiveActionId = profile.effectiveActions.max(by: { $0.value < $1.value })?.key
        if let actionId = effectiveActionId, let action = microActions.first(where: { $0.title == actionId }) {
            return action
        }
        switch signal {
        case "stress": return microActions[2] // Coherent Breathing
        case "sleep": return microActions[0] // Power Down
        case "focus": return microActions[3] // Single Task Sprint
        case "energy": return microActions[1] // Gentle Walk
        case "calendar": return microActions[5] // Buffer Block
        default: return microActions[6] // Gratitude Pause
        }
    }
    
    func selectMicroAction(insight: Insight, metrics: DailyMetrics) -> MicroAction {
        let profile = FeatureStore.shared.getProfile()
        let effectiveActionId = profile.effectiveActions.max(by: { $0.value < $1.value })?.key
        
        if let actionId = effectiveActionId,
           let effectiveAction = microActions.first(where: { $0.title == actionId }),
           effectiveAction.category == insight.recommendation.category {
            return effectiveAction
        }
        return insight.recommendation
    }
    
    func selectMicroAction(insight: Insight, metrics: DailyMetrics, profile: UserProfile) -> MicroAction {
        let baseAction = insight.recommendation
        let effectiveness = profile.effectiveActions[baseAction.title] ?? 0.5
        let learningRate = 0.3
        let adjustedScore = effectiveness + learningRate * (1.0 - effectiveness)
        if adjustedScore > 0.7 {
            return baseAction
        }
        let alternative = microActions.first(where: { $0.category == baseAction.category && $0.title != baseAction.title })
        return alternative ?? baseAction
    }
    
    func updateEffectiveness(actionId: String, wasEffective: Bool, profile: inout UserProfile) {
        let current = profile.effectiveActions[actionId] ?? 0.5
        let learningRate = 0.3
        if wasEffective {
            profile.effectiveActions[actionId] = min(1.0, current + learningRate * (1.0 - current))
        } else {
            profile.effectiveActions[actionId] = max(0.0, current * (1.0 - learningRate))
        }
    }
    
    func allActions() -> [MicroAction] {
        return microActions
    }
    
    func actionForCategory(_ category: MicroActionCategory) -> MicroAction? {
        return microActions.first { $0.category == category }
    }
}
