import Foundation

struct CoachMessage: Codable, Identifiable { let id: UUID; let date: Date; let text: String; let isUser: Bool }
struct Challenge: Codable, Identifiable { let id: UUID; let title: String; let description: String; let duration: Int; let category: String; let points: Int; let isActive: Bool }
struct JournalEntry: Codable, Identifiable { let id: UUID; let date: Date; let text: String; let moodScore: Int }
struct FocusSession: Codable, Identifiable { let id: UUID; let date: Date; let durationMinutes: Int; let completed: Bool }
struct PersonalizedContent: Codable, Identifiable { let id: UUID; let title: String; let description: String; let type: ContentType; let relevanceScore: Double; let imageURL: String? }
enum ContentType: String, Codable { case article = "Article"; case video = "Video"; case exercise = "Exercise"; case recipe = "Recipe" }
