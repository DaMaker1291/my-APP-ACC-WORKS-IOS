import SwiftUI

extension View {
    func aiGlow(color: Color = .momentumTeal, radius: CGFloat = 12) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
                .blur(radius: radius / 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
    
    func aiShimmer(duration: Double = 2.0) -> some View {
        self.modifier(ShimmerModifier(duration: duration))
    }
    
    func aiPulse(color: Color = .momentumTeal) -> some View {
        self.modifier(PulseModifier(color: color))
    }
    
    func aiNeuralBorder(color: Color = .momentumFocus) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.3), .clear, color.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
    
    func aiMorph() -> some View {
        self.modifier(MorphModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    let duration: Double
    @State private var isShimmering = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.15),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .offset(x: isShimmering ? geometry.size.width * 1.5 : -geometry.size.width * 0.5)
                    .animation(
                        Animation.linear(duration: duration).repeatForever(autoreverses: false),
                        value: isShimmering
                    )
                }
                .clipped()
            )
            .onAppear { isShimmering = true }
    }
}

struct PulseModifier: ViewModifier {
    let color: Color
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(isPulsing ? 0.4 : 0.1), lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.03 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            )
            .onAppear { isPulsing = true }
    }
}

struct MorphModifier: ViewModifier {
    @State private var morph = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(morph ? 1.02 : 0.98)
            .blur(radius: morph ? 0 : 0.5)
            .animation(
                Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
                value: morph
            )
            .onAppear { morph = true }
    }
}
