import Foundation
import SwiftUI
import Combine

@MainActor
class NutritionViewModel: ObservableObject {
    @Published var foodEntries: [FoodEntry] = []
    @Published var todayEntries: [FoodEntry] = []
    @Published var isShowingCamera = false
    @Published var isShowingBarcodeScanner = false
    @Published var recognizedFood: AIFoodRecognition?
    @Published var scannedBarcode: BarcodeFoodItem?
    @Published var restaurantResult: (meal: String, macros: MacroSummary)?
    @Published var descriptionText = ""
    @Published var isAnalyzing = false
    @Published var showRecognitionCard = false
    @Published var photoDiaryEntries: [FoodEntry] = []
    @Published var insights: [NutritionInsightEngine.NutritionInsight] = []
    
    private let foodTracker = AIFoodTracker.shared
    private let insightEngine = NutritionInsightEngine.shared
    private let defaults = UserDefaults.standard
    private let entriesKey = "momentum_food_entries"
    
    var hasPhotoEntries: Bool {
        !photoDiaryEntries.isEmpty
    }
    
    var photoEntryCount: Int {
        photoDiaryEntries.count
    }
    
    var todaysCalories: Int {
        todayEntries.reduce(0) { $0 + $1.macros.calories }
    }
    
    var todaysProtein: Double {
        todayEntries.reduce(0.0) { $0 + $1.macros.protein }
    }
    
    var todaysCarbs: Double {
        todayEntries.reduce(0.0) { $0 + $1.macros.carbs }
    }
    
    var todaysFat: Double {
        todayEntries.reduce(0.0) { $0 + $1.macros.fat }
    }
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        if let data = defaults.data(forKey: entriesKey),
           let entries = try? JSONDecoder().decode([FoodEntry].self, from: data) {
            foodEntries = entries
            refreshToday()
        }
    }
    
    private func saveEntries() {
        if let data = try? JSONEncoder().encode(foodEntries) {
            defaults.set(data, forKey: entriesKey)
        }
        refreshToday()
    }
    
    private func refreshToday() {
        todayEntries = foodEntries.filter { Calendar.current.isDateInToday($0.date) }
        photoDiaryEntries = todayEntries.filter { $0.imageData != nil }
        generateInsights()
    }
    
    private func generateInsights() {
        Task {
            let result = await insightEngine.generateInsights(from: foodEntries)
            self.insights = result
        }
    }
    
    func logFromPhoto() {
        isAnalyzing = true
        showRecognitionCard = false
        Task {
            let result = await foodTracker.recognizeFoodFromImage()
            self.recognizedFood = result
            self.showRecognitionCard = true
            self.isAnalyzing = false
        }
    }
    
    func logFromBarcode(_ barcode: String) {
        isAnalyzing = true
        Task {
            let result = await foodTracker.lookupBarcode(barcode)
            self.scannedBarcode = result
            self.isAnalyzing = false
            if let item = result {
                let entry = FoodEntry(
                    name: item.name,
                    mealType: appropriateMealType(),
                    servingSize: item.servingSize,
                    macros: MacroSummary(calories: item.calories, protein: item.proteinG, carbs: item.carbsG, fat: item.fatG, fiber: 0),
                    source: .barcode,
                    barcode: barcode
                )
                addEntry(entry)
            }
        }
    }
    
    func logFromRestaurant(_ name: String) {
        isAnalyzing = true
        Task {
            let result = await foodTracker.recognizeFromRestaurant(name: name)
            self.restaurantResult = result
            self.isAnalyzing = false
            if let (meal, macros) = result {
                let entry = FoodEntry(
                    name: meal,
                    mealType: appropriateMealType(),
                    macros: macros,
                    source: .restaurant,
                    restaurant: name
                )
                addEntry(entry)
            }
        }
    }
    
    func logFromDescription(_ description: String) {
        isAnalyzing = true
        Task {
            let result = await foodTracker.recognizeFood(description: description)
            self.recognizedFood = result
            self.isAnalyzing = false
            if let food = result {
                let entry = FoodEntry(
                    name: food.name,
                    mealType: appropriateMealType(),
                    macros: MacroSummary(calories: food.estimatedCalories, protein: food.estimatedProtein, carbs: food.estimatedCarbs, fat: food.estimatedFat, fiber: 0),
                    source: .aiPhoto
                )
                addEntry(entry)
                self.showRecognitionCard = true
            }
        }
    }
    
    func addEntry(_ entry: FoodEntry) {
        foodEntries.append(entry)
        saveEntries()
    }
    
    func deleteEntry(_ entry: FoodEntry) {
        foodEntries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func appropriateMealType() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11: return .breakfast
        case 11..<14: return .lunch
        case 14..<17: return .snack
        case 17..<22: return .dinner
        default: return .snack
        }
    }
    
    func confirmRecognition(mealType: MealType) {
        guard let food = recognizedFood else { return }
        let entry = FoodEntry(
            name: food.name,
            mealType: mealType,
            macros: MacroSummary(calories: food.estimatedCalories, protein: food.estimatedProtein, carbs: food.estimatedCarbs, fat: food.estimatedFat, fiber: 0),
            source: .aiPhoto
        )
        addEntry(entry)
        recognizedFood = nil
        showRecognitionCard = false
    }
    
    func clearToday() {
        todayEntries.forEach { deleteEntry($0) }
    }
}
