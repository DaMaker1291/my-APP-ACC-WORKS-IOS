import Foundation

actor DataService {
    static let shared = DataService()
    private var metricsHistory: [DailyMetrics] = []
    private let defaults = UserDefaults.standard
    
    func saveMetrics(_ metrics: DailyMetrics) {
        var history = loadAllMetrics()
        if let idx = history.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: metrics.date) }) {
            history[idx] = metrics
        } else {
            history.append(metrics)
        }
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: "metricsHistory")
        }
        metricsHistory = history
    }
    func loadAllMetrics() -> [DailyMetrics] {
        if let data = defaults.data(forKey: "metricsHistory"),
           let history = try? JSONDecoder().decode([DailyMetrics].self, from: data) {
            return history
        }
        return []
    }
    func todaysMetrics() -> DailyMetrics {
        let today = Date()
        return loadAllMetrics().first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) ?? DailyMetrics()
    }
    func clearAll() {
        defaults.removeObject(forKey: "metricsHistory")
        metricsHistory = []
    }
    func metricsCount() -> Int {
        return loadAllMetrics().count
    }
}
