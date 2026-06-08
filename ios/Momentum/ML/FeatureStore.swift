import Foundation

actor FeatureStore {
    static let shared = FeatureStore()
    
    private var metricsHistory: [DailyMetrics] = []
    private var userProfile: UserProfile {
        didSet { saveProfile() }
    }
    private let defaults = UserDefaults.standard
    private let profileKey = "momentum_user_profile"
    private let metricsKey = "momentum_metrics_history"
    
    init() {
        if let data = defaults.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        } else {
            userProfile = UserProfile()
        }
        if let data = defaults.data(forKey: metricsKey),
           let history = try? JSONDecoder().decode([DailyMetrics].self, from: data) {
            metricsHistory = history
        }
    }
    
    func ingest(_ metrics: DailyMetrics) {
        if let idx = metricsHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: metrics.date) }) {
            metricsHistory[idx] = metrics
        } else {
            metricsHistory.append(metrics)
            userProfile.daysTracked += 1
        }
        metricsHistory.sort { $0.date < $1.date }
        saveHistory()
        updateProfileBaselines()
    }
    
    func buildVector(for date: Date) -> FeatureVector? {
        guard let metrics = metricsHistory.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return nil
        }
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date) - 1
        let hour = calendar.component(.hour, from: date)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        let prevDayMetrics = metricsHistory.first(where: { Calendar.current.isDate($0.date, inSameDayAs: yesterday) })
        let weekMetrics = metricsHistory.filter { $0.date > calendar.date(byAdding: .day, value: -7, to: date) ?? date }
        let monthMetrics = metricsHistory.filter { $0.date > calendar.date(byAdding: .day, value: -30, to: date) ?? date }
        
        let weekSleepAvg = weekMetrics.isEmpty ? userProfile.baselineSleep : weekMetrics.map(\.sleepHours).reduce(0, +) / Double(weekMetrics.count)
        let weekStepsAvg = weekMetrics.isEmpty ? userProfile.baselineSteps : Int(weekMetrics.map(\.steps).reduce(0, +) / weekMetrics.count)
        let monthFocusAvg = monthMetrics.isEmpty ? 50 : Int(monthMetrics.map(\.focusScore).reduce(0, +) / monthMetrics.count)
        
        return FeatureVector(
            dayOfWeek: dayOfWeek,
            hour: hour,
            sleepHours: metrics.sleepHours,
            sleepQualityScore: metrics.sleepQuality.score,
            steps: metrics.steps,
            heartRateAvg: metrics.heartRateAvg,
            heartRateVariability: metrics.heartRateVariability,
            screenTimeMinutes: metrics.screenTimeMinutes,
            calendarIntensity: CalendarIntensityToInt(metrics.calendarIntensity),
            previousDayEnergy: EnergyLevelToInt(prevDayMetrics?.energyLevel ?? metrics.energyLevel),
            previousDayStress: StressLevelToInt(prevDayMetrics?.stressLevel ?? metrics.stressLevel),
            previousDayFocus: prevDayMetrics?.focusScore ?? metrics.focusScore,
            weekToDateSleepAvg: weekSleepAvg,
            weekToDateStepsAvg: weekStepsAvg,
            monthToDateFocusAvg: monthFocusAvg
        )
    }
    
    func getProfile() -> UserProfile {
        return userProfile
    }
    
    func getHistory() -> [DailyMetrics] {
        return metricsHistory
    }
    
    func recordActionResult(actionId: String, wasEffective: Bool) {
        let current = userProfile.effectiveActions[actionId] ?? 0.5
        let learningRate = 0.3
        let update = wasEffective ? current + learningRate * (1.0 - current) : current * (1.0 - learningRate)
        userProfile.effectiveActions[actionId] = min(1.0, max(0.0, update))
    }
    
    func recordTrigger(trigger: String, outcome: String) {
        let key = "\(trigger)->\(outcome)"
        userProfile.triggerPatterns[key] = (userProfile.triggerPatterns[key] ?? 0) + 1
    }
    
    func mostEffectiveAction() -> String? {
        return userProfile.effectiveActions.max(by: { $0.value < $1.value })?.key
    }
    
    func todaysMetrics() -> DailyMetrics {
        return metricsHistory.first(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) ?? DailyMetrics()
    }
    
    private func updateProfileBaselines() {
        let recent = metricsHistory.suffix(14)
        guard !recent.isEmpty else { return }
        userProfile.baselineSleep = recent.map(\.sleepHours).reduce(0, +) / Double(recent.count)
        userProfile.baselineSteps = Int(recent.map(\.steps).reduce(0, +) / recent.count)
        userProfile.baselineHRV = recent.map(\.heartRateVariability).reduce(0, +) / Double(recent.count)
        userProfile.learningVersion += 1
        saveProfile()
    }
    
    private func saveProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            defaults.set(data, forKey: profileKey)
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(metricsHistory) {
            defaults.set(data, forKey: metricsKey)
        }
    }
    
    private func CalendarIntensityToInt(_ intensity: CalendarIntensity) -> Int {
        switch intensity {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .overwhelming: return 3
        }
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
