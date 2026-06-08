import SwiftUI

struct AIScanlineView: View {
    let color: Color
    @State private var position: CGFloat = 0
    
    init(color: Color = .momentumTeal) {
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0), color.opacity(0.3), color.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 4)
                .position(x: geometry.size.width / 2, y: position)
                .blur(radius: 2)
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 3).repeatForever(autoreverses: false)
                    ) {
                        position = geometry.size.height
                    }
                }
        }
        .clipped()
    }
}
