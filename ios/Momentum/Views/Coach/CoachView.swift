import SwiftUI

struct CoachView: View {
    @State private var messages: [CoachMessage] = []
    @State private var inputText = ""
    @State private var recoveryScore = 72
    @State private var isTyping = false
    @Environment(\.colorScheme) var colorScheme
    private let personaEngine = AIPersonaEngine.shared
    private let insightEngine = InsightEngine.shared
    private let dataService = DataService.shared
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Coach")
                            .font(.momentumLargeTitle)
                            .foregroundColor(.white)
                        Text("Your personal wellness guide")
                            .font(.momentumSubheadline)
                            .foregroundColor(.momentumTextSecondary)
                    }
                    Spacer()
                    // Recovery readiness
                    VStack(spacing: 2) {
                        ScoreRing(progress: Double(recoveryScore) / 100, color: .momentumRecovery, strokeWidth: 6, label: nil, showText: true)
                            .frame(width: 48, height: 48)
                        Text("Ready")
                            .font(.momentumCaption)
                            .foregroundColor(.momentumTextSecondary)
                    }
                }
                .padding()
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                CoachBubble(message: message)
                            }
                            if isTyping {
                                HStack {
                                    Image(systemName: "brain")
                                        .foregroundColor(.momentumFocus)
                                    ThinkingDots()
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .id("typing")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: isTyping) { _, _ in
                        if isTyping {
                            withAnimation {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Journal shortcut
                MomentumCard {
                    NavigationLink(destination: JournalView()) {
                        HStack {
                            Image(systemName: "book.pencil")
                                .foregroundColor(.momentumFocus)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Quick Journal Entry")
                                    .font(.momentumCallout)
                                    .foregroundColor(.white)
                                Text("How are you feeling right now?")
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
                .padding(.bottom, 8)
                
                // Input
                HStack(spacing: 12) {
                    TextField("Ask your coach...", text: $inputText)
                        .font(.momentumBody)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.momentumGlass)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.momentumTeal)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
            }
        }
        .onAppear {
            loadInitialMessages()
        }
    }
    
    private func loadInitialMessages() {
        Task {
            let metrics = await dataService.todaysMetrics()
            let insights = await insightEngine.generateDailyInsights(from: metrics)
            let greeting = await personaEngine.coachGreeting()
            
            messages.append(CoachMessage(
                date: Date(),
                text: "\(greeting)! I've analyzed your morning data. Your recovery score is \(recoveryScore)% — \(recoveryScore > 70 ? "looking good!" : "let's focus on recovery today.")",
                isUser: false
            ))
            
            if let insight = insights.first {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let coachText = "I noticed: \(insight.title). \(insight.description) Would you like to try \(insight.recommendation.title)?"
                    messages.append(CoachMessage(date: Date(), text: coachText, isUser: false))
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messages.append(CoachMessage(date: Date(), text: text, isUser: true))
        inputText = ""
        isTyping = true
        
        Task {
            let lowercased = text.lowercased()
            var response = ""
            
            if lowercased.contains("stress") || lowercased.contains("anxious") || lowercased.contains("overwhelmed") {
                response = "I hear you. Stress is tough. Let's try a 2-minute breathing exercise. Inhale for 4 seconds, hold for 4, exhale for 6. Your vagus nerve will thank you."
            } else if lowercased.contains("sleep") || lowercased.contains("tired") || lowercased.contains("exhausted") {
                response = "Sleep is foundational. Your recent data shows room for improvement. Try powering down screens 30 minutes before bed tonight — it boosts melatonin by 50%."
            } else if lowercased.contains("focus") || lowercased.contains("distracted") || lowercased.contains("concentrate") {
                response = "Focus challenges are common. Try a Single Task Sprint — 25 minutes on one thing, no switching. Your brain will build concentration momentum."
            } else if lowercased.contains("eat") || lowercased.contains("food") || lowercased.contains("hungry") || lowercased.contains("meal") || lowercased.contains("nutrition") {
                response = "Nutrition is key for energy. Try logging your next meal with a photo — I'll recognize it instantly and track your macros."
            } else if lowercased.contains("hello") || lowercased.contains("hi") || lowercased.contains("hey") {
                response = "Hey there! I'm here to help. Ask me about sleep, focus, stress, nutrition, or anything on your mind."
            } else if lowercased.contains("thank") || lowercased.contains("thanks") {
                response = "You're welcome! Consistency is the secret. Keep showing up for yourself."
            } else {
                let metrics = await dataService.todaysMetrics()
                let insights = await insightEngine.generateDailyInsights(from: metrics)
                if let insight = insights.first {
                    response = "Based on your data: \(insight.title). \(insight.description) Want to try \(insight.recommendation.title)?"
                } else {
                    response = "I'm here to help with wellness insights. Ask me about sleep, focus, stress, or nutrition!"
                }
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isTyping = false
            messages.append(CoachMessage(date: Date(), text: response, isUser: false))
        }
    }
}

struct CoachBubble: View {
    let message: CoachMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .font(.momentumBody)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.momentumTeal.opacity(0.3))
                    .cornerRadius(20, corners: [.topLeft, .topRight, .bottomLeft])
            } else {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.momentumFocus)
                    .font(.title3)
                Text(message.text)
                    .font(.momentumBody)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.momentumGlass)
                    .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
                Spacer()
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
