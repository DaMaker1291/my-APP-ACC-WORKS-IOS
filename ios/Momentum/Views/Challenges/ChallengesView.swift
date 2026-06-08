import SwiftUI

struct ChallengesView: View {
    @State private var challenges: [Challenge] = [
        Challenge(id: UUID(), title: "7-Day Mindfulness", description: "Complete 5 minutes of mindfulness daily", duration: 7, category: "mindfulness", points: 100, isActive: true),
        Challenge(id: UUID(), title: "10K Steps Sprint", description: "Walk 10,000 steps every day for a week", duration: 7, category: "movement", points: 150, isActive: true),
        Challenge(id: UUID(), title: "Sleep Optimization", description: "Get 7+ hours of sleep for 5 nights", duration: 5, category: "sleep", points: 120, isActive: true),
        Challenge(id: UUID(), title: "Sugar Free Week", description: "No added sugar for 7 days", duration: 7, category: "nutrition", points: 200, isActive: false),
        Challenge(id: UUID(), title: "Focus Marathon", description: "Complete 5 focus sessions of 25 min each", duration: 5, category: "focus", points: 130, isActive: true),
        Challenge(id: UUID(), title: "Hydration Hero", description: "Drink 8 glasses of water daily for a week", duration: 7, category: "nutrition", points: 100, isActive: false),
        Challenge(id: UUID(), title: "Gratitude Journal", description: "Write 3 things you're grateful for each day", duration: 14, category: "mindfulness", points: 180, isActive: true),
        Challenge(id: UUID(), title: "Digital Detox", description: "No social media for 48 hours", duration: 2, category: "focus", points: 160, isActive: false),
        Challenge(id: UUID(), title: "Morning Stretch", description: "10 minute stretch every morning", duration: 10, category: "movement", points: 140, isActive: true),
        Challenge(id: UUID(), title: "Meal Prep Master", description: "Log all meals with photos for 5 days", duration: 5, category: "nutrition", points: 120, isActive: false),
    ]
    
    @State private var totalPoints = 0
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Challenges")
                                .font(.momentumLargeTitle)
                                .foregroundColor(.white)
                            Text("\(totalPoints) points earned")
                                .font(.momentumSubheadline)
                                .foregroundColor(.momentumTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .font(.title)
                            .foregroundColor(.momentumEnergy)
                    }
                    .padding(.horizontal)
                    
                    // Active challenges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(challenges.filter { $0.isActive }) { challenge in
                            ChallengeCard(challenge: challenge) {
                                toggleChallenge(challenge)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Inactive challenges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Discover")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(challenges.filter { !$0.isActive }) { challenge in
                            ChallengeCard(challenge: challenge) {
                                toggleChallenge(challenge)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
        }
        .onAppear {
            totalPoints = challenges.filter { $0.isActive }.reduce(0) { $0 + $1.points }
        }
    }
    
    private func toggleChallenge(_ challenge: Challenge) {
        if let idx = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[idx].isActive.toggle()
            totalPoints = challenges.filter { $0.isActive }.reduce(0) { $0 + $1.points }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let onToggle: () -> Void
    
    var categoryColor: Color {
        switch challenge.category {
        case "mindfulness": return .momentumFocus
        case "movement": return .momentumTeal
        case "sleep": return .momentumFocus
        case "nutrition": return .momentumEnergy
        case "focus": return .momentumFocus
        default: return .momentumTextSecondary
        }
    }
    
    var body: some View {
        Button(action: onToggle) {
            MomentumCard(glowColor: challenge.isActive ? categoryColor : nil, glowRadius: 6) {
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: challenge.isActive ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(challenge.isActive ? categoryColor : .momentumTextTertiary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title)
                            .font(.momentumCallout)
                            .foregroundColor(.white)
                        Text(challenge.description)
                            .font(.momentumCaption)
                            .foregroundColor(.momentumTextSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("\(challenge.duration)d")
                            .font(.momentumCallout)
                            .foregroundColor(challenge.isActive ? categoryColor : .momentumTextSecondary)
                        Text("\(challenge.points)pts")
                            .font(.momentumCaption)
                            .foregroundColor(.momentumTextTertiary)
                    }
                }
            }
        }
    }
}
