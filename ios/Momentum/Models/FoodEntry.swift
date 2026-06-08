import Foundation

struct FoodEntry: Codable, Identifiable {
    let id: UUID; let date: Date; let name: String; let mealType: MealType; let servingSize: String; let macros: MacroSummary; let source: FoodSource; let imageData: Data?; let barcode: String?; let restaurant: String?
    init(id: UUID = UUID(), date: Date = Date(), name: String, mealType: MealType, servingSize: String = "1 serving", macros: MacroSummary, source: FoodSource = .manual, imageData: Data? = nil, barcode: String? = nil, restaurant: String? = nil) {
        self.id = id; self.date = date; self.name = name; self.mealType = mealType; self.servingSize = servingSize; self.macros = macros; self.source = source; self.imageData = imageData; self.barcode = barcode; self.restaurant = restaurant
    }
}

struct MacroSummary: Codable { let calories: Int; let protein: Double; let carbs: Double; let fat: Double; let fiber: Double }
struct BarcodeFoodItem: Codable { let barcode: String; let name: String; let servingSize: String; let calories: Int; let proteinG: Double; let carbsG: Double; let fatG: Double }
struct AIFoodRecognition: Codable { let name: String; let estimatedCalories: Int; let estimatedProtein: Double; let estimatedCarbs: Double; let estimatedFat: Double; let confidence: Double; let alternativeNames: [String] }

enum MealType: String, Codable, CaseIterable { case breakfast = "Breakfast"; case lunch = "Lunch"; case dinner = "Dinner"; case snack = "Snack" }
enum FoodSource: String, Codable { case aiPhoto = "AI Photo"; case barcode = "Barcode"; case restaurant = "Restaurant"; case manual = "Manual" }
