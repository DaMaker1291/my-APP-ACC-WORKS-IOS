import Foundation

actor InsightEngine {
    static let shared = InsightEngine()
    
    private let microActions: [MicroAction] = [
        MicroAction(title: "Power Down", description: "Turn off screens 30 mins before bed", duration: 1800, category: .rest, scienceNote: "Blue light suppresses melatonin production by up to 50%"),
        MicroAction(title: "Gentle Walk", description: "Take a 10-minute walk outdoors", duration: 600, category: .movement, scienceNote: "Walking increases blood flow to the brain by 20%"),
        MicroAction(title: "Coherent Breathing", description: "Breathe at 5 breaths per minute", duration: 300, category: .breathing, scienceNote: "Box breathing activates the vagus nerve, lowering heart rate"),
        MicroAction(title: "Single Task Sprint", description: "Focus on one task for 25 minutes", duration: 1500, category: .focus, scienceNote: "Single-tasking reduces cortisol and increases output quality"),
        MicroAction(title: "Digital Reset", description: "No screens for 1 hour", duration: 3600, category: .reset, scienceNote: "Digital detox lowers anxiety and improves sleep quality"),
        MicroAction(title: "Buffer Block", description: "Schedule 15 min gap between meetings", duration: 900, category: .rest, scienceNote: "Transition buffers reduce cognitive switching costs by 40%"),
        MicroAction(title: "Gratitude Pause", description: "Write down 3 things you're grateful for", duration: 120, category: .mindfulness, scienceNote: "Gratitude journaling increases long-term well-being by 10%"),
        MicroAction(title: "Stretch Break", description: "Do 5 minutes of full body stretches", duration: 300, category: .movement, scienceNote: "Stretching releases muscle tension and improves circulation"),
        MicroAction(title: "Deep Water", description: "Drink 500ml of water slowly", duration: 120, category: .reset, scienceNote: "Even 1% dehydration reduces cognitive performance by 12%"),
        MicroAction(title: "Sunlight Exposure", description: "Get 10 minutes of natural light", duration: 600, category: .reset, scienceNote: "Morning sunlight sets circadian rhythm for the day"),
    ]
    
    func generateDailyInsights(from metrics: DailyMetrics) -> [Insight] {
        var insights: [Insight] = []
        
        // Sleep insights
        if metrics.sleepHours < 6 {
            insights.append(Insight(
                title: "Low Sleep Detected",
                description: "You got only \(String(format: "%.1f", metrics.sleepHours)) hours of sleep. This impacts cognitive function and emotional regulation.",
                category: .sleep,
                severity: metrics.sleepHours < 4 ? .critical : .warning,
                recommendation: microActions.first { $0.category == .rest } ?? microActions[0]
            ))
        } else if metrics.sleepHours >= 8 {
            insights.append(Insight(
                title: "Great Sleep Quality",
                description: "You slept \(String(format: "%.1f", metrics.sleepHours)) hours with \(metrics.sleepQuality.rawValue) quality. Keep it up!",
                category: .sleep,
                severity: .info,
                recommendation: microActions.first { $0.category == .mindfulness } ?? microActions[6]
            ))
        }
        
        // Movement insights
        if metrics.steps < 3000 {
            insights.append(Insight(
                title: "Low Movement Today",
                description: "Only \(metrics.steps) steps today. Sedentary patterns reduce energy and focus.",
                category: .movement,
                severity: metrics.steps < 1000 ? .critical : .warning,
                recommendation: microActions.first { $0.title == "Gentle Walk" } ?? microActions[1]
            ))
        } else if metrics.steps > 12000 {
            insights.append(Insight(
                title: "High Physical Activity",
                description: "Great job with \(metrics.steps) steps! Ensure proper recovery.",
                category: .movement,
                severity: .info,
                recommendation: microActions.first { $0.title == "Stretch Break" } ?? microActions[7]
            ))
        }
        
        // Focus insights
        if metrics.focusScore < 35 {
            insights.append(Insight(
                title: "Focus Struggling",
                description: "Your focus score is \(metrics.focusScore). Try a single-tasking session to rebuild concentration.",
                category: .focus,
                severity: metrics.focusScore < 25 ? .critical : .warning,
                recommendation: microActions.first { $0.title == "Single Task Sprint" } ?? microActions[3]
            ))
        } else if metrics.focusScore > 75 {
            insights.append(Insight(
                title: "Deep Focus Mode",
                description: "Your focus score of \(metrics.focusScore) is excellent. Protect this state.",
                category: .focus,
                severity: .info,
                recommendation: microActions.first { $0.title == "Buffer Block" } ?? microActions[5]
            ))
        }
        
        // Stress insights
        if metrics.stressLevel == .high || metrics.stressLevel == .veryHigh {
            insights.append(Insight(
                title: "Elevated Stress",
                description: "Your stress level is \(metrics.stressLevel.rawValue). Your body needs recovery.",
                category: .stress,
                severity: metrics.stressLevel == .veryHigh ? .critical : .warning,
                recommendation: microActions.first { $0.title == "Coherent Breathing" } ?? microActions[2]
            ))
        }
        
        // Screen time insights
        if metrics.screenTimeMinutes > 360 {
            insights.append(Insight(
                title: "Excessive Screen Time",
                description: "\(Int(metrics.screenTimeMinutes)) minutes on screens today. Consider a digital reset.",
                category: .recovery,
                severity: metrics.screenTimeMinutes > 480 ? .critical : .warning,
                recommendation: microActions.first { $0.title == "Digital Reset" } ?? microActions[4]
            ))
        }
        
        // Calendar intensity insights
        if metrics.calendarIntensity == .high || metrics.calendarIntensity == .overwhelming {
            insights.append(Insight(
                title: "Calendar Overload",
                description: "You have \(metrics.calendarEventCount) events today. Back-to-back meetings drain energy.",
                category: .combined,
                severity: metrics.calendarIntensity == .overwhelming ? .critical : .warning,
                recommendation: microActions.first { $0.title == "Buffer Block" } ?? microActions[5]
            ))
        }
        
        // Combined: Sleep + Calendar insights
        if metrics.sleepHours < 6 && metrics.calendarIntensity == .high {
            insights.append(Insight(
                title: "Burnout Risk Detected",
                description: "Low sleep (\(String(format: "%.1f", metrics.sleepHours))h) combined with heavy calendar load increases burnout risk by 3x.",
                category: .combined,
                severity: .critical,
                recommendation: microActions.first { $0.title == "Power Down" } ?? microActions[0]
            ))
        }
        
        return insights
    }
    
    func generateInsights(from metricsHistory: [DailyMetrics]) -> [Insight] {
        guard metricsHistory.count >= 3 else {
            return generateDailyInsights(from: metricsHistory.last ?? DailyMetrics())
        }
        var insights = generateDailyInsights(from: metricsHistory.last ?? DailyMetrics())
        let recent = metricsHistory.suffix(7)
        let avgSleep = recent.map(\.sleepHours).reduce(0, +) / Double(recent.count)
        let avgSteps = recent.map(\.steps).reduce(0, +) / recent.count
        let avgFocus = recent.map(\.focusScore).reduce(0, +) / recent.count
        
        if avgSleep < 6 {
            insights.append(Insight(
                title: "Chronic Sleep Deprivation",
                description: "Averaging only \(String(format: "%.1f", avgSleep)) hours over the last \(recent.count) days. This accumulates as sleep debt.",
                category: .sleep,
                severity: .critical,
                recommendation: microActions.first { $0.title == "Power Down" } ?? microActions[0]
            ))
        }
        if avgSteps < 4000 {
            insights.append(Insight(
                title: "Persistently Sedentary",
                description: "Averaging \(avgSteps) steps per day. Aim for at least 6000 to maintain cardiovascular health.",
                category: .movement,
                severity: .warning,
                recommendation: microActions.first { $0.title == "Gentle Walk" } ?? microActions[1]
            ))
        }
        if avgFocus < 40 {
            insights.append(Insight(
                title: "Sustained Focus Challenges",
                description: "Focus has been consistently low (\(avgFocus) avg). Consider a focus habit.",
                category: .focus,
                severity: .warning,
                recommendation: microActions.first { $0.title == "Single Task Sprint" } ?? microActions[3]
            ))
        }
        return insights
    }
    
    func allMicroActions() -> [MicroAction] {
        return microActions
    }
    
    func microAction(for category: MicroActionCategory) -> MicroAction? {
        return microActions.first { $0.category == category }
    }
}
