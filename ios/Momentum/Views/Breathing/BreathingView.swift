import SwiftUI

struct BreathingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var phase: BreathingParticleRing.BreathingPhase = .inhale
    @State private var phaseTimeRemaining: Double = 4
    @State private var totalTimeRemaining: Int = 60
    @State private var isActive = false
    @State private var cyclesCompleted = 0
    @State private var timer: Timer?
    
    private let totalDuration = 60
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            if !isActive {
                // Start screen
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "wind.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.momentumTeal)
                    
                    Text("Guided Breathing")
                        .font(.momentumLargeTitle)
                        .foregroundColor(.white)
                    
                    Text("Inhale 4s • Hold 4s • Exhale 6s • Rest 2s")
                        .font(.momentumBody)
                        .foregroundColor(.momentumTextSecondary)
                    
                    Text("60 seconds • Reduces stress and anxiety")
                        .font(.momentumSubheadline)
                        .foregroundColor(.momentumTextTertiary)
                    
                    Spacer()
                    
                    Button(action: startBreathing) {
                        Text("Begin")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.momentumTeal)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.momentumCallout)
                            .foregroundColor(.momentumTextSecondary)
                    }
                    
                    Spacer().frame(height: 40)
                }
            } else {
                // Active breathing
                VStack(spacing: 32) {
                    // Close button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.momentumTextSecondary)
                                .padding()
                                .background(Color.momentumGlass)
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("\(totalTimeRemaining)s")
                            .font(.momentumTitle2)
                            .foregroundColor(.white)
                            .monospacedDigit()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Breathing ring
                    BreathingParticleRing(phase: $phase, color: currentColor)
                        .frame(width: 240, height: 240)
                    
                    // Phase label
                    Text(phaseLabel)
                        .font(.momentumLargeTitle)
                        .foregroundColor(currentColor)
                        .contentTransition(.numericText())
                    
                    Text("\(Int(phaseTimeRemaining))")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                    
                    Spacer()
                    
                    // Progress
                    Text("\(cyclesCompleted) cycles complete")
                        .font(.momentumSubheadline)
                        .foregroundColor(.momentumTextSecondary)
                    
                    Button(action: {
                        isActive = false
                        stopTimer()
                    }) {
                        Text("End Session")
                            .font(.momentumCallout)
                            .foregroundColor(.momentumStress)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            phase = .inhale
            phaseTimeRemaining = phase.duration
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var phaseLabel: String {
        switch phase {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .rest: return "Rest"
        }
    }
    
    private var currentColor: Color {
        switch phase {
        case .inhale: return .momentumTeal
        case .hold: return .momentumEnergy
        case .exhale: return .momentumFocus
        case .rest: return .momentumRecovery
        }
    }
    
    private func startBreathing() {
        isActive = true
        totalTimeRemaining = totalDuration
        phase = .inhale
        phaseTimeRemaining = 4
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            phaseTimeRemaining -= 0.1
            totalTimeRemaining -= 1
            
            if phaseTimeRemaining <= 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = phase.next
                    phaseTimeRemaining = phase.duration
                }
                if phase == .inhale || phase == .rest {
                    cyclesCompleted += 1
                }
            }
            
            if totalTimeRemaining <= 0 {
                stopTimer()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
