import SwiftUI

struct FocusView: View {
    @State private var selectedDuration: TimeInterval = 1500
    @State private var timeRemaining: TimeInterval = 1500
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var sessionsCompleted = 0
    @State private var totalMinutes = 0
    @State private var showBreathing = false
    @State private var timer: Timer?
    @State private var progress: Double = 1.0
    @State private var startTime: Date?
    
    let durations: [(label: String, seconds: TimeInterval)] = [
        ("25 min", 1500), ("15 min", 900), ("45 min", 2700), ("60 min", 3600)
    ]
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Focus")
                                .font(.momentumLargeTitle)
                                .foregroundColor(.white)
                            Text("\(sessionsCompleted) sessions • \(totalMinutes) min total")
                                .font(.momentumSubheadline)
                                .foregroundColor(.momentumTextSecondary)
                        }
                        Spacer()
                        Button(action: { showBreathing.toggle() }) {
                            Image(systemName: "wind")
                                .font(.title2)
                                .foregroundColor(.momentumTeal)
                                .padding()
                                .background(Color.momentumGlass)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Timer
                    VStack(spacing: 20) {
                        ZStack {
                            // Ring
                            ScoreRing(progress: progress, color: isRunning ? .momentumTeal : .momentumFocus, strokeWidth: 12, label: nil, showText: false)
                                .frame(width: 220, height: 220)
                            
                            // Text
                            VStack(spacing: 4) {
                                Text(timeString(from: timeRemaining))
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Text(isRunning ? (isPaused ? "Paused" : "Focusing...") : "Ready")
                                    .font(.momentumSubheadline)
                                    .foregroundColor(isPaused ? .momentumEnergy : .momentumTextSecondary)
                            }
                        }
                        
                        // Duration picker
                        HStack(spacing: 12) {
                            ForEach(durations, id: \.seconds) { duration in
                                Button(action: {
                                    guard !isRunning else { return }
                                    selectedDuration = duration.seconds
                                    timeRemaining = duration.seconds
                                    progress = 1.0
                                }) {
                                    Text(duration.label)
                                        .font(.momentumCallout)
                                        .foregroundColor(selectedDuration == duration.seconds ? .white : .momentumTextSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedDuration == duration.seconds ? Color.momentumFocus : Color.momentumGlass)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        
                        // Controls
                        HStack(spacing: 24) {
                            if isRunning {
                                Button(action: resetTimer) {
                                    Image(systemName: "stop.fill")
                                        .font(.title2)
                                        .foregroundColor(.momentumStress)
                                        .padding()
                                        .background(Color.momentumStress.opacity(0.15))
                                        .clipShape(Circle())
                                }
                                
                                Button(action: togglePause) {
                                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                        .font(.title)
                                        .foregroundColor(.momentumTeal)
                                        .padding(24)
                                        .background(Color.momentumTeal.opacity(0.15))
                                        .clipShape(Circle())
                                }
                            } else {
                                Button(action: startTimer) {
                                    Image(systemName: "play.fill")
                                        .font(.title)
                                        .foregroundColor(.momentumFocus)
                                        .padding(24)
                                        .background(Color.momentumFocus.opacity(0.15))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.momentumGlass)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    // Session Stats
                    MomentumCard {
                        HStack(spacing: 0) {
                            StatItem(value: "\(sessionsCompleted)", label: "Sessions", icon: "checkmark.circle")
                            Divider().background(Color.white.opacity(0.1))
                            StatItem(value: "\(totalMinutes)", label: "Minutes", icon: "clock")
                            Divider().background(Color.white.opacity(0.1))
                            StatItem(value: "\(sessionsCompleted > 0 ? totalMinutes / sessionsCompleted : 0)", label: "Avg Min", icon: "chart.bar")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Week Chart
                    MomentumCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.momentumFocus)
                                Text("Focus This Week")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            WeekBarChart(
                                values: [0.6, 0.8, 0.4, 0.7, 0.5, 0.3, 0.0],
                                color: .momentumFocus,
                                labels: ["M", "T", "W", "T", "F", "S", "S"]
                            )
                            .frame(height: 100)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Breathing Shortcut
                    MomentumCard(glowColor: .momentumTeal, glowRadius: 8) {
                        Button(action: { showBreathing.toggle() }) {
                            HStack {
                                Image(systemName: "wind.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.momentumTeal)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Need a Reset?")
                                        .font(.momentumCallout)
                                        .foregroundColor(.white)
                                    Text("Try a guided breathing exercise")
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
        .sheet(isPresented: $showBreathing) {
            BreathingView()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timeRemaining = selectedDuration
        progress = 1.0
        startTime = Date()
        isRunning = true
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                timeRemaining -= 1
                progress = timeRemaining / selectedDuration
                if timeRemaining <= 0 {
                    completeSession()
                }
            }
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
    }
    
    private func resetTimer() {
        stopTimer()
        timeRemaining = selectedDuration
        progress = 1.0
        isRunning = false
        isPaused = false
    }
    
    private func completeSession() {
        stopTimer()
        sessionsCompleted += 1
        totalMinutes += Int(selectedDuration / 60)
        isRunning = false
        progress = 0
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.momentumFocus)
            Text(value)
                .font(.momentumTitle3)
                .foregroundColor(.white)
            Text(label)
                .font(.momentumCaption)
                .foregroundColor(.momentumTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
