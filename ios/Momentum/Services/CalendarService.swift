import Foundation
import EventKit

actor CalendarService {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                let (granted, _) = try await eventStore.requestFullAccessToEvents()
                return granted
            } catch {
                return false
            }
        } else {
            do {
                let granted = try await eventStore.requestAccess(to: .event)
                return granted
            } catch {
                return false
            }
        }
    }
    func fetchTodayEvents() async -> [EKEvent] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        let pred = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: pred)
    }
    func todaysCalendarIntensity() async -> CalendarIntensity {
        let events = await fetchTodayEvents()
        switch events.count {
        case 0...2: return .low
        case 3...5: return .medium
        case 6...8: return .high
        default: return .overwhelming
        }
    }
}
