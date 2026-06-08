import SwiftUI

struct ProfileView: View {
    @State private var streakDays = 12
    @State private var mindfulMinutes = 347
    @State private var challengesCompleted = 8
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var healthKitEnabled = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Avatar & Name
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.momentumFocus, .momentumTeal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 88, height: 88)
                            Text("You")
                                .font(.momentumLargeTitle)
                                .foregroundColor(.white)
                        }
                        Text("Your Journey")
                            .font(.momentumTitle2)
                            .foregroundColor(.white)
                        Text("Day \(streakDays) of consistency")
                            .font(.momentumSubheadline)
                            .foregroundColor(.momentumTextSecondary)
                    }
                    .padding(.top)
                    
                    // Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        StatCard(value: "\(streakDays)", label: "Day Streak", icon: "flame.fill", color: .momentumEnergy)
                        StatCard(value: "\(mindfulMinutes)", label: "Mindful Min", icon: "brain", color: .momentumFocus)
                        StatCard(value: "\(challengesCompleted)", label: "Challenges", icon: "trophy.fill", color: .momentumTeal)
                    }
                    .padding(.horizontal)
                    
                    // Badges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Badges")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                BadgeView(icon: "flame.fill", label: "7-Day Streak", color: .momentumEnergy, earned: true)
                                BadgeView(icon: "moon.stars.fill", label: "Sleep Master", color: .momentumFocus, earned: true)
                                BadgeView(icon: "fork.knife", label: "Food Logger", color: .momentumTeal, earned: true)
                                BadgeView(icon: "figure.walk", label: "10K Steps", color: .momentumRecovery, earned: false)
                                BadgeView(icon: "drop.fill", label: "Hydration", color: .momentumTeal, earned: false)
                                BadgeView(icon: "timer", label: "Focus Pro", color: .momentumFocus, earned: false)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            QuickActionCard(icon: "book.pencil", label: "Journal", color: .momentumFocus)
                            QuickActionCard(icon: "trophy", label: "Challenges", color: .momentumEnergy, destination: AnyView(ChallengesView()))
                            QuickActionCard(icon: "figure.walk", label: "Exercise", color: .momentumTeal)
                            QuickActionCard(icon: "chart.bar.xaxis", label: "Reports", color: .momentumFocus)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        MomentumCard {
                            VStack(spacing: 16) {
                                SettingToggleRow(icon: "bell.fill", title: "Notifications", isOn: $notificationsEnabled)
                                Divider().background(Color.white.opacity(0.06))
                                SettingToggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $darkModeEnabled)
                                Divider().background(Color.white.opacity(0.06))
                                SettingToggleRow(icon: "heart.fill", title: "HealthKit Sync", isOn: $healthKitEnabled)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Digital Wellbeing
                    MomentumCard {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.momentumTeal)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Digital Wellbeing")
                                    .font(.momentumCallout)
                                    .foregroundColor(.white)
                                Text("Screen time: 4h 32m today")
                                    .font(.momentumCaption)
                                    .foregroundColor(.momentumTextSecondary)
                            }
                            Spacer()
                            Text("-12% vs yesterday")
                                .font(.momentumCaption)
                                .foregroundColor(.momentumRecovery)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        MomentumCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(value)
                    .font(.momentumTitle2)
                    .foregroundColor(.white)
                Text(label)
                    .font(.momentumCaption)
                    .foregroundColor(.momentumTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct BadgeView: View {
    let icon: String
    let label: String
    let color: Color
    let earned: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(earned ? color.opacity(0.15) : Color.momentumGlass)
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(earned ? color : .momentumTextTertiary)
            }
            Text(label)
                .font(.momentumCaption)
                .foregroundColor(earned ? .white : .momentumTextTertiary)
        }
        .frame(width: 80)
    }
}

struct QuickActionCard: View {
    let icon: String
    let label: String
    let color: Color
    var destination: AnyView?
    @State private var showDestination = false
    
    var body: some View {
        Button(action: {
            if destination != nil {
                showDestination.toggle()
            }
        }) {
            MomentumCard {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(label)
                        .font(.momentumCallout)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showDestination) {
            destination
        }
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.momentumTextSecondary)
            Text(title)
                .font(.momentumCallout)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(.momentumTeal)
        }
    }
}
