import SwiftUI

struct NutritionDashboardView: View {
    @StateObject private var viewModel = NutritionViewModel()
    @State private var showMealLog = false
    @State private var showCamera = false
    @State private var selectedInsight: NutritionInsightEngine.NutritionInsight?
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nutrition")
                                .font(.momentumLargeTitle)
                                .foregroundColor(.white)
                            Text("\(viewModel.todayEntries.count) meals logged today")
                                .font(.momentumSubheadline)
                                .foregroundColor(.momentumTextSecondary)
                        }
                        Spacer()
                        Button(action: { showMealLog.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.momentumTeal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Camera Hero
                    Button(action: { showCamera.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.momentumTeal.opacity(0.2), .momentumFocus.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 140)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.momentumTeal.opacity(0.2), lineWidth: 1)
                                )
                            
                            HStack(spacing: 20) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 44))
                                    .foregroundColor(.momentumTeal)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Snap a Meal")
                                        .font(.momentumTitle3)
                                        .foregroundColor(.white)
                                    Text("AI recognizes food instantly")
                                        .font(.momentumCaption)
                                        .foregroundColor(.momentumTextSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.momentumTextTertiary)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Macro Rings
                    MomentumCard {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "chart.pie")
                                    .foregroundColor(.momentumEnergy)
                                Text("Today's Macros")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            HStack(spacing: 24) {
                                MacroRingChart(current: Double(viewModel.todaysCalories), goal: 2000, color: .momentumEnergy, label: "Calories", unit: "cal")
                                MacroRingChart(current: viewModel.todaysProtein, goal: 80, color: .momentumFocus, label: "Protein", unit: "g")
                                MacroRingChart(current: viewModel.todaysCarbs, goal: 250, color: .momentumTeal, label: "Carbs", unit: "g")
                                MacroRingChart(current: viewModel.todaysFat, goal: 65, color: .momentumStress, label: "Fat", unit: "g")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Meal Timeline
                    if !viewModel.todayEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meal Timeline")
                                .font(.momentumHeadline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.todayEntries) { entry in
                                        MealTimelineCard(entry: entry)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Photo Diary
                    if viewModel.hasPhotoEntries {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Photo Diary")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(viewModel.photoEntryCount) photos")
                                    .font(.momentumCaption)
                                    .foregroundColor(.momentumTextSecondary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.photoDiaryEntries) { entry in
                                        if let data = entry.imageData, let image = UIImage(data: data) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(12)
                                        }
                                    }
                                    Button(action: { showCamera.toggle() }) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.momentumTeal.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "plus")
                                                    .foregroundColor(.momentumTeal)
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Calorie Chart
                    MomentumCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar")
                                    .foregroundColor(.momentumEnergy)
                                Text("Calorie Trend")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            let calories: [Double] = (0..<7).map { day in
                                let date = Calendar.current.date(byAdding: .day, value: -(6 - day), to: Date()) ?? Date()
                                let entries = viewModel.foodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                                return Double(entries.reduce(0) { $0 + $1.macros.calories })
                            }
                            WeekBarChart(values: calories.map { $0 / 2500.0 }, color: .momentumEnergy, labels: ["M", "T", "W", "T", "F", "S", "S"])
                                .frame(height: 100)
                        }
                    }
                    .padding(.horizontal)
                    
                    // AI Insights
                    if !viewModel.insights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Insights")
                                .font(.momentumHeadline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.insights) { insight in
                                Button(action: { selectedInsight = insight }) {
                                    MomentumCard {
                                        HStack {
                                            Image(systemName: insight.severity == .warning ? "exclamationmark.triangle" : insight.severity == .critical ? "exclamationmark.circle" : "lightbulb")
                                                .foregroundColor(insight.severity == .warning ? .momentumEnergy : insight.severity == .critical ? .momentumStress : .momentumTeal)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(insight.title)
                                                    .font(.momentumCallout)
                                                    .foregroundColor(.white)
                                                Text(insight.description)
                                                    .font(.momentumCaption)
                                                    .foregroundColor(.momentumTextSecondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Water Tracker
                    MomentumCard {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.momentumTeal)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hydration")
                                    .font(.momentumCallout)
                                    .foregroundColor(.white)
                                Text("3 of 8 glasses logged")
                                    .font(.momentumCaption)
                                    .foregroundColor(.momentumTextSecondary)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(0..<8) { i in
                                    Circle()
                                        .fill(i < 3 ? Color.momentumTeal : Color.momentumGlass)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(viewModel: viewModel)
        }
        .sheet(isPresented: $showMealLog) {
            MealLogView(viewModel: viewModel)
        }
        .alert(item: $selectedInsight) { insight in
            Alert(
                title: Text(insight.title),
                message: Text("\(insight.description)\n\nRecommendation: \(insight.recommendation)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct MealTimelineCard: View {
    let entry: FoodEntry
    
    var body: some View {
        VStack(spacing: 8) {
            if let data = entry.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.momentumGlass)
                        .frame(width: 80, height: 80)
                    Image(systemName: "fork.knife")
                        .foregroundColor(.momentumTextSecondary)
                }
            }
            Text(entry.name)
                .font(.momentumCaption)
                .foregroundColor(.white)
                .lineLimit(1)
            Text(entry.mealType.rawValue)
                .font(.momentumCaption)
                .foregroundColor(.momentumTextTertiary)
        }
        .frame(width: 90)
    }
}
