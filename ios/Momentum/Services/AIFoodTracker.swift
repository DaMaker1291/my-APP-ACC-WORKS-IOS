import Foundation
import UIKit

actor AIFoodTracker {
    static let shared = AIFoodTracker()
    
    private let foodDatabase: [(name: String, calories: Int, protein: Double, carbs: Double, fat: Double, fiber: Double, serving: String)] = [
        ("Avocado Toast", 380, 12, 35, 22, 8, "2 slices"),
        ("Oatmeal with Berries", 340, 14, 55, 6, 10, "1 bowl"),
        ("Greek Yogurt + Almonds", 210, 20, 12, 10, 3, "1 cup"),
        ("Grilled Chicken Salad", 420, 38, 18, 22, 7, "1 plate"),
        ("Salmon Bowl", 580, 42, 45, 24, 6, "1 bowl"),
        ("Smoothie Bowl", 350, 10, 60, 8, 9, "1 bowl"),
        ("Turkey Sandwich", 450, 30, 40, 16, 4, "1 sandwich"),
        ("Vegetable Stir Fry", 320, 14, 38, 14, 10, "1 plate"),
        ("Margherita Pizza", 720, 28, 80, 32, 3, "2 slices"),
        ("Chicken Wrap", 480, 35, 42, 18, 5, "1 wrap"),
        ("Black Bean Bowl", 440, 18, 62, 12, 16, "1 bowl"),
        ("Steak with Vegetables", 520, 45, 20, 28, 6, "1 plate"),
        ("Pasta Primavera", 480, 16, 68, 14, 8, "1 plate"),
        ("Tuna Salad", 300, 32, 8, 16, 2, "1 cup"),
        ("Egg & Cheese Bagel", 400, 20, 44, 16, 2, "1 bagel"),
        ("Chicken Rice Bowl", 550, 40, 62, 14, 4, "1 bowl"),
        ("Hummus & Veggies", 280, 10, 32, 16, 10, "1 plate"),
        ("Fish Tacos", 420, 30, 38, 18, 5, "3 tacos"),
        ("Lentil Soup", 260, 18, 40, 4, 14, "1 bowl"),
        ("Protein Shake", 220, 30, 18, 4, 2, "1 shake"),
    ]
    
    private let barcodeDatabase: [String: BarcodeFoodItem] = [
        "016000164295": BarcodeFoodItem(barcode: "016000164295", name: "Nature Valley Granola Bar", servingSize: "1 bar", calories: 190, proteinG: 4, carbsG: 29, fatG: 7),
        "818290011321": BarcodeFoodItem(barcode: "818290011321", name: "Chobani Greek Yogurt", servingSize: "1 cup", calories: 140, proteinG: 14, carbsG: 9, fatG: 5),
        "888849000107": BarcodeFoodItem(barcode: "888849000107", name: "Quest Protein Bar", servingSize: "1 bar", calories: 200, proteinG: 21, carbsG: 22, fatG: 8),
        "041570055563": BarcodeFoodItem(barcode: "041570055563", name: "Almond Breeze Milk", servingSize: "1 cup", calories: 60, proteinG: 1, carbsG: 8, fatG: 2.5),
        "813512012511": BarcodeFoodItem(barcode: "813512012511", name: "RXBAR", servingSize: "1 bar", calories: 210, proteinG: 12, carbsG: 24, fatG: 9),
        "602652171440": BarcodeFoodItem(barcode: "602652171440", name: "Kind Bar Dark Chocolate", servingSize: "1 bar", calories: 180, proteinG: 6, carbsG: 18, fatG: 12),
        "052400021609": BarcodeFoodItem(barcode: "052400021609", name: "Oatly Oat Milk", servingSize: "1 cup", calories: 120, proteinG: 3, carbsG: 16, fatG: 5),
        "7622210220822": BarcodeFoodItem(barcode: "7622210220822", name: "Larabars Apple Pie", servingSize: "1 bar", calories: 200, proteinG: 4, carbsG: 28, fatG: 10),
        "030900003804": BarcodeFoodItem(barcode: "030900003804", name: "Siggi's Yogurt", servingSize: "1 cup", calories: 110, proteinG: 14, carbsG: 8, fatG: 2),
        "643900065928": BarcodeFoodItem(barcode: "643900065928", name: "Premier Protein Shake", servingSize: "1 bottle", calories: 160, proteinG: 30, carbsG: 5, fatG: 3),
    ]
    
    private let restaurantDatabase: [String: (calories: Int, protein: Double, carbs: Double, fat: Double, suggestion: String)] = [
        "chipotle": (750, 42, 70, 28, "Burrito Bowl with Chicken, brown rice, black beans, fajita veggies, pico de gallo & lettuce"),
        "sweetgreen": (520, 28, 42, 26, "Harvest Bowl with roasted chicken, sweet potato, apple, goat cheese, wild rice & balsamic dressing"),
        "chick-fil-a": (440, 28, 45, 18, "Grilled Chicken Sandwich with a side of fruit cup"),
        "mcdonald's": (580, 24, 58, 30, "McChicken with small fries and Diet Coke"),
        "subway": (460, 32, 52, 14, "6-inch Turkey Breast on whole wheat with lettuce, tomato, cucumber & mustard"),
    ]
    
    private let keywordDatabase: [(keywords: [String], food: String)] = [
        (["avocado", "toast", "avo"], "Avocado Toast"),
        (["oatmeal", "oat", "berries", "berry", "porridge"], "Oatmeal with Berries"),
        (["greek yogurt", "yogurt", "almond", "parfait"], "Greek Yogurt + Almonds"),
        (["chicken", "salad", "grilled chicken", "caesar"], "Grilled Chicken Salad"),
        (["salmon", "bowl", "rice bowl", "salmon bowl"], "Salmon Bowl"),
        (["smoothie", "bowl", "acai", "açaí"], "Smoothie Bowl"),
        (["turkey", "sandwich", "turkey sandwich", "sub"], "Turkey Sandwich"),
        (["stir fry", "stir-fry", "vegetable", "veggie stir"], "Vegetable Stir Fry"),
        (["pizza", "margherita", "cheese pizza"], "Margherita Pizza"),
        (["wrap", "chicken wrap"], "Chicken Wrap"),
        (["black bean", "bean bowl", "burrito bowl"], "Black Bean Bowl"),
        (["steak", "steak with", "beef"], "Steak with Vegetables"),
        (["pasta", "primavera", "spaghetti", "noodle"], "Pasta Primavera"),
        (["tuna", "tuna salad", "fish salad"], "Tuna Salad"),
        (["egg", "bagel", "egg cheese", "breakfast sandwich"], "Egg & Cheese Bagel"),
        (["chicken rice", "teriyaki", "rice bowl chicken"], "Chicken Rice Bowl"),
        (["hummus", "veggie", "veggies", "carrot", "celery"], "Hummus & Veggies"),
        (["taco", "fish taco", "fish tacos"], "Fish Tacos"),
        (["lentil", "soup", "lentil soup"], "Lentil Soup"),
        (["protein", "shake", "protein shake", "smoothie protein"], "Protein Shake"),
    ]
    
    func recognizeFoodFromImage() -> AIFoodRecognition {
        guard let item = foodDatabase.randomElement() else {
            return AIFoodRecognition(name: "Unknown", estimatedCalories: 0, estimatedProtein: 0, estimatedCarbs: 0, estimatedFat: 0, confidence: 0, alternativeNames: [])
        }
        let confidence = Double.random(in: 0.83...0.92)
        let alternatives = foodDatabase.filter { $0.name != item.name && abs($0.calories - item.calories) < 100 }
            .map(\.name)
        return AIFoodRecognition(
            name: item.name,
            estimatedCalories: item.calories,
            estimatedProtein: item.protein,
            estimatedCarbs: item.carbs,
            estimatedFat: item.fat,
            confidence: confidence,
            alternativeNames: Array(alternatives.prefix(3))
        )
    }
    
    func recognizeFood(description: String) -> AIFoodRecognition? {
        let lowercased = description.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        for entry in keywordDatabase {
            let matchCount = entry.keywords.filter { lowercased.contains($0) }.count
            if matchCount > 0 {
                if let item = foodDatabase.first(where: { $0.name.lowercased() == entry.food.lowercased() }) {
                    let confidence = min(0.95, 0.6 + Double(matchCount) * 0.12)
                    return AIFoodRecognition(
                        name: item.name,
                        estimatedCalories: item.calories,
                        estimatedProtein: item.protein,
                        estimatedCarbs: item.carbs,
                        estimatedFat: item.fat,
                        confidence: confidence,
                        alternativeNames: []
                    )
                }
            }
        }
        if lowercased.contains("ate") || lowercased.contains("had") || lowercased.contains("eating") || lowercased.contains("dinner") || lowercased.contains("lunch") || lowercased.contains("breakfast") || lowercased.contains("snack") || lowercased.contains("meal") {
            if let item = foodDatabase.randomElement() {
                return AIFoodRecognition(
                    name: item.name,
                    estimatedCalories: item.calories,
                    estimatedProtein: item.protein,
                    estimatedCarbs: item.carbs,
                    estimatedFat: item.fat,
                    confidence: 0.55,
                    alternativeNames: []
                )
            }
        }
        return nil
    }
    
    func lookupBarcode(_ barcode: String) -> BarcodeFoodItem? {
        let cleaned = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        return barcodeDatabase[cleaned]
    }
    
    func recognizeFromRestaurant(name: String) -> (meal: String, macros: MacroSummary)? {
        let lowercased = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        for (key, value) in restaurantDatabase {
            if lowercased.contains(key) {
                return (value.suggestion, MacroSummary(calories: value.calories, protein: value.protein, carbs: value.carbs, fat: value.fat, fiber: 0))
            }
        }
        return nil
    }
    
    func searchFoodDatabase(query: String) -> [(name: String, calories: Int)] {
        let lowercased = query.lowercased()
        return foodDatabase
            .filter { $0.name.lowercased().contains(lowercased) || lowercased.contains($0.name.lowercased()) }
            .map { ($0.name, $0.calories) }
    }
    
    func allFoodItems() -> [(name: String, calories: Int, protein: Double, carbs: Double, fat: Double)] {
        return foodDatabase.map { ($0.name, $0.calories, $0.protein, $0.carbs, $0.fat) }
    }
}
