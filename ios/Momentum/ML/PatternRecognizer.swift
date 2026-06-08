import Foundation

actor PatternRecognizer {
    static let shared = PatternRecognizer()
    
    private var featureStore: FeatureStore { .shared }
    
    private let microActions: [MicroAction] = [
        MicroAction(title: "Power Down", description: "Turn off screens 30 mins before bed", duration: 1800, category: .rest),
        MicroAction(title: "Gentle Walk", description: "Take a 10-minute walk outdoors", duration: 600, category: .movement),
        MicroAction(title: "Coherent Breathing", description: "Breathe at 5 breaths per minute", duration: 300, category: .breathing),
        MicroAction(title: "Single Task Sprint", description: "Focus on one task for 25 minutes", duration: 1500, category: .focus),
        MicroAction(title: "Digital Reset", description: "No screens for 1 hour", duration: 3600, category: .reset),
        MicroAction(title: "Buffer Block", description: "Schedule 15 min gap between meetings", duration: 900, category: .rest),
        MicroAction(title: "Gratitude Pause", description: "Write 3 things you're grateful for", duration: 120, category: .mindfulness),
    ]
    
    func detectPatterns() -> [Pattern] {
        let history = featureStore.getHistory()
        guard history.count >= 5 else { return [] }
        
        var patterns: [Pattern] = []
        
        if let weekly = detectWeeklyPattern(history) { patterns.append(weekly) }
        if let trigger = detectTriggerPattern(history) { patterns.append(trigger) }
        if let sleepCorr = detectSleepCorrelation(history) { patterns.append(sleepCorr) }
        if let anomaly = detectAnomaly(history) { patterns.append(anomaly) }
        if let calendar = detectCalendarPattern(history) { patterns.append(calendar) }
        
        return patterns
    }
    
    private func detectWeeklyPattern(_ history: [DailyMetrics]) -> Pattern? {
        guard history.count >= 7 else { return nil }
        let recent = history.suffix(14)
        var dayEnergy: [Int: [Double]] = [:]
        for metrics in recent {
            let day = Calendar.current.component(.weekday, from: metrics.date)
            dayEnergy[day, default: []].append(Double(EnergyLevelToInt(metrics.energyLevel)))
        }
        var minDay = 0
        var minAvg = Double.infinity
        for (day, values) in dayEnergy {
            let avg = values.reduce(0, +) / Double(values.count)
            if avg < minAvg && values.count >= 2 {
                minAvg = avg
                minDay = day
            }
        }
        guard minAvg < 2.0 else { return nil }
        let dayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let dayName = dayNames[safe: minDay] ?? "Unknown"
        let frequency = Double(dayEnergy[minDay]?.count ?? 0) / Double(recent.count) * 100
        return Pattern(
            id: UUID(),
            type: .weekly,
            description: "Your lowest energy consistently falls on \(dayName)s (avg \(String(format: "%.1f", minAvg))/4).",
            frequency: frequency,
            strength: 1.0 - (minAvg / 4.0),
            actionable: true,
            suggestedAction: microActions.first { $0.category == .rest }
        )
    }
    
    private func detectTriggerPattern(_ history: [DailyMetrics]) -> Pattern? {
        guard history.count >= 10 else { return nil }
        let recent = history.suffix(14)
        var highStressCount = 0
        var highStressWithLowSleep = 0
        for metrics in recent {
            let isHighStress = metrics.stressLevel == .high || metrics.stressLevel == .veryHigh
            if isHighStress {
                highStressCount += 1
                if metrics.sleepHours < 6 { highStressWithLowSleep += 1 }
            }
        }
        guard highStressCount >= 2 else { return nil }
        let ratio = Double(highStressWithLowSleep) / Double(highStressCount)
        guard ratio > 0.5 else { return nil }
        return Pattern(
            id: UUID(),
            type: .trigger,
            description: "High stress days follow low sleep \(Int(ratio * 100))% of the time.",
            frequency: ratio * 100,
            strength: ratio,
            actionable: true,
            suggestedAction: microActions.first { $0.title == "Power Down" }
        )
    }
    
    private func detectSleepCorrelation(_ history: [DailyMetrics]) -> Pattern? {
        guard history.count >= 7 else { return nil }
        let recent = history.suffix(14)
        let sleepHours = recent.map(\.sleepHours)
        let focusScores = recent.map(\.focusScore)
        guard sleepHours.count == focusScores.count else { return nil }
        let meanSleep = sleepHours.reduce(0, +) / Double(sleepHours.count)
        let meanFocus = Double(focusScores.reduce(0, +)) / Double(focusScores.count)
        var num: Double = 0
        var denomSleep: Double = 0
        var denomFocus: Double = 0
        for i in 0..<sleepHours.count {
            let ds = sleepHours[i] - meanSleep
            let df = Double(focusScores[i]) - meanFocus
            num += ds * df
            denomSleep += ds * ds
            denomFocus += df * df
        }
        let correlation = sqrt(denomSleep * denomFocus) > 0 ? num / sqrt(denomSleep * denomFocus) : 0
        guard abs(correlation) > 0.3 else { return nil }
        return Pattern(
            id: UUID(),
            type: .correlation,
            description: "Sleep and focus have a \(correlation > 0 ? "positive" : "negative") correlation of \(String(format: "%.2f", correlation)).",
            frequency: abs(correlation) * 100,
            strength: abs(correlation),
            actionable: true,
            suggestedAction: microActions.first { $0.category == .rest }
        )
    }
    
    private func detectAnomaly(_ history: [DailyMetrics]) -> Pattern? {
        guard history.count >= 7 else { return nil }
        let recent = history.suffix(7)
        let avgSteps = recent.map(\.steps).reduce(0, +) / recent.count
        let avgSleep = recent.map(\.sleepHours).reduce(0, +) / Double(recent.count)
        let stdSteps = sqrt(recent.map { pow(Double($0.steps - avgSteps), 2) }.reduce(0, +) / Double(recent.count))
        let stdSleep = sqrt(recent.map { pow($0.sleepHours - avgSleep, 2) }.reduce(0, +) / Double(recent.count))
        guard let lastMetrics = history.last else { return nil }
        let stepsZScore = stdSteps > 0 ? abs(Double(lastMetrics.steps - avgSteps)) / stdSteps : 0
        let sleepZScore = stdSleep > 0 ? abs(lastMetrics.sleepHours - avgSleep) / stdSleep : 0
        guard stepsZScore > 2 || sleepZScore > 2 else { return nil }
        let description: String
        let action: MicroAction?
        if stepsZScore > 2 {
            description = "Unusual step count (\(lastMetrics.steps)) — \(lastMetrics.steps > avgSteps ? "much higher" : "much lower") than your average of \(avgSteps)."
            action = microActions.first { $0.category == .movement }
        } else {
            description = "Unusual sleep (\(String(format: "%.1f", lastMetrics.sleepHours))h) — \(lastMetrics.sleepHours > avgSleep ? "much more" : "much less") than your average of \(String(format: "%.1f", avgSleep))h."
            action = microActions.first { $0.category == .rest }
        }
        return Pattern(
            id: UUID(),
            type: .anomaly,
            description: description,
            frequency: max(stepsZScore, sleepZScore) * 20,
            strength: min(1.0, max(stepsZScore, sleepZScore) / 3.0),
            actionable: true,
            suggestedAction: action
        )
    }
    
    private func detectCalendarPattern(_ history: [DailyMetrics]) -> Pattern? {
        guard history.count >= 7 else { return nil }
        let recent = history.suffix(14)
        let highCalendarDays = recent.filter { $0.calendarIntensity == .high || $0.calendarIntensity == .overwhelming }
        guard !highCalendarDays.isEmpty else { return nil }
        let avgEnergyOnHighCalendar = Double(highCalendarDays.map { EnergyLevelToInt($0.energyLevel) }.reduce(0, +)) / Double(highCalendarDays.count)
        let lowEnergyDays = highCalendarDays.filter { $0.energyLevel == .low || $0.energyLevel == .veryLow }.count
        let ratio = Double(lowEnergyDays) / Double(highCalendarDays.count)
        guard ratio > 0.3 else { return nil }
        return Pattern(
            id: UUID(),
            type: .trigger,
            description: "\(Int(ratio * 100))% of high-calendar days result in low energy. Your schedule impacts your well-being.",
            frequency: ratio * 100,
            strength: ratio,
            actionable: true,
            suggestedAction: microActions.first { $0.title == "Buffer Block" }
        )
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
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
