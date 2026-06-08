import SwiftUI

struct MoodReactiveBackground: View {
    let energyLevel: EnergyLevel
    let stressLevel: StressLevel
    @State private var animate = false
    
    private var gradientColors: [Color] {
        let baseEnergy: Color = {
            switch energyLevel {
            case .veryLow, .low: return .momentumBg
            case .moderate: return Color(hex: "#1A1A2E")
            case .high: return Color(hex: "#1A2A1A")
            case .veryHigh: return Color(hex: "#1A2A1A")
            }
        }()
        let accent: Color = {
            switch stressLevel {
            case .low: return .momentumTeal
            case .moderate: return .momentumEnergy
            case .high: return .momentumFocus
            case .veryHigh: return .momentumStress
            }
        }()
        return [baseEnergy, accent.opacity(0.15), baseEnergy]
    }
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            LinearGradient(
                colors: gradientColors,
                startPoint: animate ? .topLeading : .bottomLeading,
                endPoint: animate ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}

struct MoodBubble: View {
    let energyLevel: EnergyLevel
    let stressLevel: StressLevel
    @State private var pulse = false
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [accentColor.opacity(0.3), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 120
                )
            )
            .frame(width: 200, height: 200)
            .scaleEffect(pulse ? 1.2 : 0.8)
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
    
    private var accentColor: Color {
        switch energyLevel {
        case .veryLow, .low: return .momentumFocus
        case .moderate: return .momentumEnergy
        case .high, .veryHigh: return .momentumTeal
        }
    }
}
