import SwiftUI

struct PersonalizedReelsFeed: View {
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var timerProgress: Double = 0
    @State private var showGamification = false
    @State private var isComplete = false
    @State private var timer: Timer?
    
    private let autoAdvanceDuration: TimeInterval = 15
    
    let reels: [ScoredReel]
    
    init(reels: [ScoredReel] = []) {
        self.reels = reels
    }
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            if reels.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "play.rectangle")
                        .font(.system(size: 60))
                        .foregroundColor(.momentumTextTertiary)
                    Text("No reels available")
                        .font(.momentumHeadline)
                        .foregroundColor(.momentumTextSecondary)
                }
            } else {
                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.momentumTeal)
                                .frame(width: geometry.size.width * timerProgress, height: 3)
                                .animation(.linear(duration: 0.1), value: timerProgress)
                        }
                        .padding(.top, 8)
                        .padding(.horizontal)
                    }
                    .frame(height: 10)
                    
                    // Reel content
                    GeometryReader { geometry in
                        let size = geometry.size
                        ZStack {
                            ForEach(Array(reels.enumerated()), id: \.offset) { index, scored in
                                ReelCardView(scored: scored, isActive: index == currentIndex)
                                    .frame(width: size.width, height: size.height)
                                    .offset(y: CGFloat(index - currentIndex) * size.height + dragOffset)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                dragOffset = value.translation.height
                                                pauseTimer()
                                            }
                                            .onEnded { value in
                                                let threshold = size.height * 0.3
                                                if value.translation.height < -threshold && currentIndex < reels.count - 1 {
                                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                        currentIndex += 1
                                                        dragOffset = 0
                                                    }
                                                    resetTimer()
                                                } else if value.translation.height > threshold && currentIndex > 0 {
                                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                        currentIndex -= 1
                                                        dragOffset = 0
                                                    }
                                                    resetTimer()
                                                } else {
                                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                        dragOffset = 0
                                                    }
                                                    resetTimer()
                                                }
                                                if currentIndex == reels.count - 1 {
                                                    isComplete = true
                                                    showGamification = true
                                                }
                                            }
                                    )
                            }
                        }
                    }
                    
                    // Dot indicators
                    HStack(spacing: 6) {
                        ForEach(0..<reels.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.momentumTeal : Color.white.opacity(0.2))
                                .frame(width: index == currentIndex ? 8 : 6, height: index == currentIndex ? 8 : 6)
                                .animation(.easeInOut, value: currentIndex)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if showGamification {
                GamificationOverlay(isComplete: isComplete) {
                    showGamification = false
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timerProgress = 0
        let step = 0.1 / autoAdvanceDuration
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timerProgress += step
            if timerProgress >= 1.0 {
                timerProgress = 0
                if currentIndex < reels.count - 1 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentIndex += 1
                    }
                } else {
                    isComplete = true
                    showGamification = true
                    stopTimer()
                }
            }
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        timerProgress = 0
        startTimer()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ScoredReel: Identifiable {
    let id: UUID
    let reel: ExerciseReel
    let score: Double
    let reason: String
}
