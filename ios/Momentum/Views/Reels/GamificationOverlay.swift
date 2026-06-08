import SwiftUI

struct GamificationOverlay: View {
    let isComplete: Bool
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.momentumBg.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 24) {
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.momentumTeal)
                    
                    Text("Great Job!")
                        .font(.momentumLargeTitle)
                        .foregroundColor(.white)
                    
                    Text("You completed all reels. Your body and mind will thank you.")
                        .font(.momentumBody)
                        .foregroundColor(.momentumTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    HStack(spacing: 20) {
                        StatBadge(value: "3", label: "Exercises", icon: "figure.walk")
                        StatBadge(value: "22", label: "Minutes", icon: "clock")
                        StatBadge(value: "85", label: "Score", icon: "star")
                    }
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.momentumFocus)
                    
                    Text("Continue Your Streak!")
                        .font(.momentumTitle2)
                        .foregroundColor(.white)
                    
                    Text("Just one more reel to complete today's routine.")
                        .font(.momentumBody)
                        .foregroundColor(.momentumTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Button(action: onDismiss) {
                    Text(isComplete ? "Done" : "Continue")
                        .font(.momentumHeadline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 14)
                        .background(isComplete ? Color.momentumTeal : Color.momentumFocus)
                        .cornerRadius(14)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1
                    opacity = 1
                }
            }
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.momentumTeal)
            Text(value)
                .font(.momentumTitle3)
                .foregroundColor(.white)
            Text(label)
                .font(.momentumCaption)
                .foregroundColor(.momentumTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.momentumGlass)
        .cornerRadius(12)
    }
}
