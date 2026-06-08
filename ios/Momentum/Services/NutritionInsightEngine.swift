import Foundation

actor NutritionInsightEngine {
    static let shared = NutritionInsightEngine()
    
    struct NutritionInsight: Codable, Identifiable {
        let id: UUID
        let title: String
        let description: String
        let severity: InsightSeverity
        let recommendation: String
        init(id: UUID = UUID(), title: String, description: String, severity: InsightSeverity, recommendation: String) {
            self.id = id; self.title = title; self.description = description; self.severity = severity; self.recommendation = recommendation
        }
    }
    
    func generateInsights(from entries: [FoodEntry]) -> [NutritionInsight] {
        var insights: [NutritionInsight] = []
        
        let todayEntries = entries.filter { Calendar.current.isDateInToday($0.date) }
        let weekEntries = entries.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
        let photoEntries = todayEntries.filter { $0.source == .aiPhoto }
        let barcodeEntries = todayEntries.filter { $0.source == .barcode }
        let restaurantEntries = todayEntries.filter { $0.source == .restaurant }
        
        if todayEntries.isEmpty {
            insights.append(NutritionInsight(
                title: "No Meals Logged Today",
                description: "Start tracking your nutrition with a quick photo or description.",
                severity: .info,
                recommendation: "Take a photo of your next meal or type what you ate."
            ))
        }
        
        if photoEntries.isEmpty && !todayEntries.isEmpty {
            insights.append(NutritionInsight(
                title: "Try Photo Logging",
                description: "You haven't used AI photo recognition today. It's the fastest way to log.",
                severity: .info,
                recommendation: "Snap a photo of your meal for instant AI recognition."
            ))
        }
        
        let totalProtein = todayEntries.reduce(0.0) { $0 + $1.macros.protein }
        if totalProtein < 40 && !todayEntries.isEmpty {
            insights.append(NutritionInsight(
                title: "Low Protein Intake",
                description: "Only \(Int(totalProtein))g protein today. Aim for 20-30g per meal for satiety and muscle maintenance.",
                severity: .warning,
                recommendation: "Add a protein-rich food like Greek yogurt, eggs, or lean meat."
            ))
        }
        
        let totalCalories = todayEntries.reduce(0) { $0 + $1.macros.calories }
        if totalCalories < 800 && !todayEntries.isEmpty {
            insights.append(NutritionInsight(
                title: "Very Low Calorie Intake",
                description: "Only \(totalCalories) calories today. Very low intake can slow metabolism and reduce energy.",
                severity: .critical,
                recommendation: "Consider a balanced meal with protein, healthy fats, and complex carbs."
            ))
        }
        
        if barcodeEntries.isEmpty && !todayEntries.isEmpty {
            insights.append(NutritionInsight(
                title: "Barcode Scanning Available",
                description: "Scan barcodes for instant, accurate nutrition data from packaged foods.",
                severity: .info,
                recommendation: "Try scanning the barcode on your next packaged food item."
            ))
        }
        
        if restaurantEntries.count > 2 {
            insights.append(NutritionInsight(
                title: "Frequent Restaurant Meals",
                description: "You've logged \(restaurantEntries.count) restaurant meals today. Restaurant meals average 50% more calories than home-cooked.",
                severity: .warning,
                recommendation: "Balance restaurant meals with home-cooked whole foods."
            ))
        }
        
        let mealTypesLogged = Set(todayEntries.map(\.mealType))
        if mealTypesLogged.count < 3 && todayEntries.count >= 2 {
            let missing = MealType.allCases.filter { !mealTypesLogged.contains($0) }
            insights.append(NutritionInsight(
                title: "Missing Meal Type",
                description: "You haven't logged \(missing.map(\.rawValue).joined(separator: " or ")) yet. Regular eating patterns stabilize blood sugar.",
                severity: .info,
                recommendation: "Log your \(missing.first?.rawValue ?? "next meal") for a complete picture."
            ))
        }
        
        let totalFiber = todayEntries.reduce(0.0) { $0 + $1.macros.fiber }
        if totalFiber < 15 && !todayEntries.isEmpty {
            insights.append(NutritionInsight(
                title: "Fiber Intake Low",
                description: "Only \(Int(totalFiber))g fiber today. Aim for 25-30g for digestive health and satiety.",
                severity: .info,
                recommendation: "Add beans, lentils, vegetables, or whole grains to your next meal."
            ))
        }
        
        let uniqueRestaurants = Set(weekEntries.compactMap(\.restaurant))
        if uniqueRestaurants.count >= 3 {
            insights.append(NutritionInsight(
                title: "Restaurant Variety This Week",
                description: "You've eaten at \(uniqueRestaurants.count) different restaurants this week.",
                severity: .info,
                recommendation: "Track which restaurants align best with your nutrition goals."
            ))
        }
        
        if entries.count >= 20 {
            insights.append(NutritionInsight(
                title: "Consistent Logger! 🎉",
                description: "You've logged \(entries.count) meals total. Consistent tracking is the #1 predictor of nutrition success.",
                severity: .info,
                recommendation: "Keep it up! Review your weekly patterns for insights."
            ))
        }
        
        let mealTimes = todayEntries.compactMap { entry -> Date? in
            return entry.date
        }.sorted()
        if mealTimes.count >= 2 {
            let gaps = zip(mealTimes, mealTimes.dropFirst()).map { $1.timeIntervalSince($0) / 3600 }
            if let maxGap = gaps.max(), maxGap > 6 {
                insights.append(NutritionInsight(
                    title: "Large Gap Between Meals",
                    description: "\(Int(maxGap)) hours between meals can cause energy dips and overeating later.",
                    severity: .info,
                    recommendation: "Try a small protein-rich snack to bridge long gaps."
                ))
            }
        }
        
        return insights
    }
    
    func hydrationReminder() -> NutritionInsight {
        NutritionInsight(
            title: "Hydration Check",
            description: "Even mild dehydration reduces focus and energy. Aim for 8 glasses daily.",
            severity: .info,
            recommendation: "Drink a glass of water now."
        )
    }
}
