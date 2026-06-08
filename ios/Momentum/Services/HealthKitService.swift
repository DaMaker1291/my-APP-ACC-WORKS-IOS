import Foundation
import HealthKit

actor HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    private let allTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
    ]
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: allTypes)
            return true
        } catch {
            return false
        }
    }
    func fetchTodayMetrics() async -> DailyMetrics {
        var metrics = DailyMetrics()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return metrics }
        let pred = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        if let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            let steps = try? await withCheckedThrowingContinuation { (c: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
                    c.resume(returning: stats?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
                }
                healthStore.execute(query)
            }
            metrics.steps = Int(steps ?? 0)
        }
        if let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            let hrv = try? await withCheckedThrowingContinuation { (c: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: hrvType, quantitySamplePredicate: pred, options: .discreteAverage) { _, stats, _ in
                    c.resume(returning: stats?.averageQuantity()?.doubleValue(for: HKUnit.secondUnit(with: .milli)) ?? 0)
                }
                healthStore.execute(query)
            }
            metrics.heartRateVariability = hrv ?? 0
        }
        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            let hr = try? await withCheckedThrowingContinuation { (c: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: pred, options: .discreteAverage) { _, stats, _ in
                    c.resume(returning: stats?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0)
                }
                healthStore.execute(query)
            }
            metrics.heartRateAvg = hr ?? 0
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            let samples = try? await withCheckedThrowingContinuation { (c: CheckedContinuation<[HKCategorySample], Error>) in
                let query = HKSampleQuery(sampleType: sleepType, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                    c.resume(returning: samples as? [HKCategorySample] ?? [])
                }
                healthStore.execute(query)
            }
            let totalSleep = (samples ?? []).reduce(0.0) { $0 + ($1.endDate.timeIntervalSince($1.startDate) / 3600.0) }
            metrics.sleepHours = totalSleep
            switch totalSleep {
            case ..<4: metrics.sleepQuality = .poor
            case ..<5.5: metrics.sleepQuality = .fair
            case ..<7: metrics.sleepQuality = .average
            case ..<8.5: metrics.sleepQuality = .good
            default: metrics.sleepQuality = .excellent
            }
        }
        return metrics
    }
}
