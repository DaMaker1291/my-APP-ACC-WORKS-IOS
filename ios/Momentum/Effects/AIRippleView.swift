import SwiftUI

struct AIRippleView: View {
    let color: Color
    let count: Int
    @State private var ripples: [Ripple] = []
    
    struct Ripple: Identifiable {
        let id = UUID()
        var scale: Double
        var opacity: Double
    }
    
    init(color: Color = .momentumTeal, count: Int = 3) {
        self.color = color
        self.count = count
    }
    
    var body: some View {
        ZStack {
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(color.opacity(ripple.opacity), lineWidth: 1.5)
                    .scaleEffect(ripple.scale)
            }
        }
        .onAppear {
            startRipples()
        }
    }
    
    private func startRipples() {
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                let ripple = Ripple(scale: 0.3, opacity: 0.6)
                ripples.append(ripple)
                withAnimation(
                    Animation.easeOut(duration: 2).repeatForever(autoreverses: false)
                ) {
                    if let idx = ripples.firstIndex(where: { $0.id == ripple.id }) {
                        ripples[idx].scale = 1.5
                        ripples[idx].opacity = 0
                    }
                }
            }
        }
    }
}
