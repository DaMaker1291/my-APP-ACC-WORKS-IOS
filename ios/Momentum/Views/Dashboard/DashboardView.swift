import SwiftUI

struct DashboardView: View {
    @State private var showLifeAudit = false
    @State private var aiInsight = "Loading your personalized insight..."
    @State private var confidence: Double = 0
    @State private var forecast: [(hour: Int, level: EnergyLevel)] = []
    @State private var overallScore = 50
    @State private var sleepScore = 50
    @State private var energyScore = 50
    @State private var focusScore = 50
    @State private var stressScore = 50
    @State private var recoveryScore = 50
    @State private var metrics = DailyMetrics()
    @State private var showBreathingPrompt = false
    @State private var shieldActive = false
    @State private var weekValues: [Double] = [0.5, 0.6, 0.45, 0.7, 0.55, 0.65, 0.5]
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today")
                                .font(.momentumLargeTitle)
                                .foregroundColor(.white)
                            Text(formattedDate())
                                .font(.momentumSubheadline)
                                .foregroundColor(.momentumTextSecondary)
                        }
                        Spacer()
                        Button(action: { showLifeAudit.toggle() }) {
                            Image(systemName: "chart.pie.fill")
                                .font(.title2)
                                .foregroundColor(.momentumTeal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Energy Blob
                    EnergyBlobView(energyLevel: metrics.energyLevel, stressLevel: metrics.stressLevel)
                        .frame(height: 160)
                        .padding(.horizontal)
                    
                    // AI Insight
                    MomentumCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "brain")
                                    .foregroundColor(.momentumFocus)
                                Text("AI Insight")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(confidence * 100))% confidence")
                                    .font(.momentumCaption)
                                    .foregroundColor(.momentumTextSecondary)
                            }
                            Text(aiInsight)
                                .font(.momentumBody)
                                .foregroundColor(.momentumTextSecondary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Energy Forecast
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "cloud.sun")
                                .foregroundColor(.momentumEnergy)
                            Text("Energy Forecast")
                                .font(.momentumHeadline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ForEach(forecast.prefix(4), id: \.hour) { item in
                                ForecastBlock(hour: item.hour, level: item.level)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Anti-Burnout Shield
                    MomentumCard(glowColor: shieldActive ? .momentumRecovery : nil) {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: shieldActive ? "shield.fill" : "shield")
                                    .foregroundColor(shieldActive ? .momentumRecovery : .momentumTextSecondary)
                                    .font(.title2)
                                Text("Anti-Burnout Shield")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                Spacer()
                                if shieldActive {
                                    Text("ACTIVE")
                                        .font(.momentumCaption)
                                        .foregroundColor(.momentumRecovery)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.momentumRecovery.opacity(0.15))
                                        .cornerRadius(6)
                                }
                            }
                            if shieldActive {
                                Text("Recovery mode engaged. Your calendar and sleep data suggest high burnout risk.")
                                    .font(.momentumBody)
                                    .foregroundColor(.momentumTextSecondary)
                                Button(action: { showBreathingPrompt.toggle() }) {
                                    Label("Start Recovery Breathing", systemImage: "wind")
                                        .font(.momentumCallout)
                                        .foregroundColor(.momentumRecovery)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.momentumRecovery.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            } else {
                                Text("You're in good shape. Keep balancing effort with recovery.")
                                    .font(.momentumBody)
                                    .foregroundColor(.momentumTextSecondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sub-score Rings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Score")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            TinyScoreRing(progress: Double(overallScore) / 100, color: .momentumTeal, label: "Overall")
                            TinyScoreRing(progress: Double(energyScore) / 100, color: .momentumEnergy, label: "Energy")
                            TinyScoreRing(progress: Double(focusScore) / 100, color: .momentumFocus, label: "Focus")
                            TinyScoreRing(progress: Double(stressScore) / 100, color: .momentumStress, label: "Stress")
                            TinyScoreRing(progress: Double(recoveryScore) / 100, color: .momentumRecovery, label: "Recovery")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Week Chart
                    MomentumCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.momentumTeal)
                                Text("This Week")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(weekValues.reduce(0, +) / Double(weekValues.count) * 100))% avg")
                                    .font(.momentumSubheadline)
                                    .foregroundColor(.momentumTextSecondary)
                            }
                            WeekBarChart(values: weekValues, color: .momentumTeal)
                                .frame(height: 100)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Micro-action breathing prompt
                    MomentumCard(glowColor: .momentumTeal, glowRadius: 12) {
                        Button(action: { showBreathingPrompt.toggle() }) {
                            HStack {
                                Image(systemName: "wind.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.momentumTeal)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Quick Breathing Exercise")
                                        .font(.momentumCallout)
                                        .foregroundColor(.white)
                                    Text("60 seconds • Reduce stress now")
                                        .font(.momentumCaption)
                                        .foregroundColor(.momentumTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.momentumTextTertiary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showLifeAudit) {
            LifeAuditView()
        }
        .sheet(isPresented: $showBreathingPrompt) {
            BreathingView()
        }
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        Task {
            let ml = LocalMLService.shared
            let metrics = await DataService.shared.todaysMetrics()
            self.metrics = metrics
            
            let (insightText, conf) = await ml.generateAIAugmentedInsight(from: metrics)
            aiInsight = insightText
            confidence = conf
            
            forecast = await ml.generateEnergyForecast()
            
            let scores = await ml.todaysIntegratedScore()
            overallScore = scores.overall
            sleepScore = scores.sleep
            energyScore = scores.energy
            focusScore = scores.focus
            stressScore = scores.stress
            recoveryScore = scores.recovery
            
            // Check burnout risk
            if metrics.sleepHours < 5.5 && (metrics.calendarIntensity == .high || metrics.calendarIntensity == .overwhelming) {
                shieldActive = true
            }
            
            // Generate week values
            let history = await DataService.shared.loadAllMetrics()
            let week = history.suffix(7)
            if week.count == 7 {
                weekValues = week.map { Double($0.focusScore) / 100.0 }
            }
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

struct EnergyBlobView: View {
    let energyLevel: EnergyLevel
    let stressLevel: StressLevel
    @State private var pulse = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(blobColor)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                    .blur(radius: 40)
                    .scaleEffect(pulse ? 1.1 : 0.9)
                    .offset(x: pulse ? 10 : -10, y: pulse ? -10 : 10)
                
                Circle()
                    .fill(blobColor.opacity(0.5))
                    .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
                    .blur(radius: 30)
                    .scaleEffect(pulse ? 0.9 : 1.1)
                    .offset(x: pulse ? -15 : 15, y: pulse ? 15 : -15)
                
                VStack(spacing: 4) {
                    Text(energyLevel.rawValue)
                        .font(.momentumTitle2)
                        .foregroundColor(.white)
                    Text("Energy")
                        .font(.momentumSubheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(
                Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
                value: pulse
            )
            .onAppear { pulse = true }
        }
    }
    
    private var blobColor: Color {
        switch energyLevel {
        case .veryLow: return .momentumFocus
        case .low: return .momentumFocus
        case .moderate: return .momentumEnergy
        case .high: return .momentumTeal
        case .veryHigh: return .momentumTeal
        }
    }
}

struct ForecastBlock: View {
    let hour: Int
    let level: EnergyLevel
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(iconColor)
            Text(level.rawValue)
                .font(.momentumCaption)
                .foregroundColor(.momentumTextSecondary)
                .multilineTextAlignment(.center)
            Text("\(hour):00")
                .font(.momentumCaption)
                .foregroundColor(.momentumTextTertiary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.momentumGlass)
        .cornerRadius(12)
    }
    
    private var iconName: String {
        switch level {
        case .veryLow: return "zzz"
        case .low: return "cloud.drizzle"
        case .moderate: return "cloud.sun"
        case .high: return "sun.max"
        case .veryHigh: return "sparkles"
        }
    }
    
    private var iconColor: Color {
        switch level {
        case .veryLow: return .momentumFocus
        case .low: return .momentumTextSecondary
        case .moderate: return .momentumEnergy
        case .high: return .momentumTeal
        case .veryHigh: return .momentumEnergy
        }
    }
}

struct LifeAuditView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Text("Life Audit")
                            .font(.momentumLargeTitle)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.momentumTextSecondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    AuditCategory(title: "Sleep", score: 75, color: .momentumFocus, details: "Avg 7.2h • Quality: Good")
                    AuditCategory(title: "Energy", score: 60, color: .momentumEnergy, details: "Peak at 10AM • Low at 3PM")
                    AuditCategory(title: "Focus", score: 55, color: .momentumFocus, details: "4.2h deep work • 6 interruptions")
                    AuditCategory(title: "Stress", score: 70, color: .momentumStress, details: "2 high-stress events this week")
                    AuditCategory(title: "Recovery", score: 65, color: .momentumRecovery, details: "HRV 42ms • 7h sleep avg")
                    AuditCategory(title: "Movement", score: 45, color: .momentumTeal, details: "5,200 steps avg • 2 active days")
                    AuditCategory(title: "Nutrition", score: 60, color: .momentumEnergy, details: "3 meals logged • 65g protein avg")
                    
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.momentumTeal)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }
}

struct AuditCategory: View {
    let title: String
    let score: Int
    let color: Color
    let details: String
    
    var body: some View {
        MomentumCard {
            HStack {
                ScoreRing(progress: Double(score) / 100, color: color, strokeWidth: 6, label: nil)
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.momentumHeadline)
                        .foregroundColor(.white)
                    Text(details)
                        .font(.momentumCaption)
                        .foregroundColor(.momentumTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.momentumTextTertiary)
            }
        }
        .padding(.horizontal)
    }
}
