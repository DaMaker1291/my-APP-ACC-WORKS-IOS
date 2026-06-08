import SwiftUI

struct AIGlowRing: View {
    let color: Color
    let size: CGFloat
    @State private var pulse = false
    
    init(color: Color = .momentumTeal, size: CGFloat = 200) {
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(color.opacity(0.1), lineWidth: 2)
                .frame(width: size, height: size)
                .scaleEffect(pulse ? 1.08 : 1.0)
            
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 1.5)
                .frame(width: size * 0.85, height: size * 0.85)
                .scaleEffect(pulse ? 0.95 : 1.02)
            
            // Center glow
            Circle()
                .fill(color.opacity(0.05))
                .frame(width: size * 0.5, height: size * 0.5)
                .blur(radius: 20)
                .scaleEffect(pulse ? 1.1 : 0.9)
        }
        .animation(
            Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
            value: pulse
        )
        .onAppear { pulse = true }
    }
}

struct AIPulsingGlow: View {
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.15))
            .frame(width: 100, height: 100)
            .scaleEffect(isAnimating ? 1.5 : 0.8)
            .opacity(isAnimating ? 0 : 0.5)
            .animation(
                Animation.easeInOut(duration: 2).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}
