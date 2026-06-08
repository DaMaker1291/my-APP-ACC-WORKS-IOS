import Foundation

struct ExerciseReel: Codable, Identifiable {
    let id: UUID; let title: String; let description: String; let duration: TimeInterval; let category: ReelCategory; let iconName: String; let colorHex: String; let scienceNote: String
    enum ReelCategory: String, Codable { case strength = "Strength"; case mobility = "Mobility"; case cardio = "Cardio"; case mindfulness = "Mindfulness"; case recovery = "Recovery" }
}
