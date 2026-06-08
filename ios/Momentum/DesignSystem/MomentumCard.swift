import SwiftUI

struct MomentumCard<Content: View>: View {
    let glowColor: Color?
    let glowRadius: CGFloat
    let content: Content
    
    init(glowColor: Color? = nil, glowRadius: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.glowColor = glowColor
        self.glowRadius = glowRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color.momentumGlass)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: (glowColor ?? .clear).opacity(0.3), radius: glowRadius, x: 0, y: 0)
    }
}

struct MomentumCardModifier: ViewModifier {
    let glowColor: Color?
    let glowRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.momentumGlass)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: (glowColor ?? .clear).opacity(0.3), radius: glowRadius, x: 0, y: 0)
    }
}

extension View {
    func momentumCard(glowColor: Color? = nil, glowRadius: CGFloat = 8) -> some View {
        modifier(MomentumCardModifier(glowColor: glowColor, glowRadius: glowRadius))
    }
}
