import SwiftUI

struct AIThinkingView: View {
    @State private var isAnimating = false
    let text: String
    
    init(text: String = "Analyzing") {
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.momentumCallout)
                .foregroundColor(.momentumTextSecondary)
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.momentumTeal)
                    .frame(width: 6, height: 6)
                    .offset(y: isAnimating ? -6 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

struct ThinkingDots: View {
    @State private var dotCount = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.momentumTextSecondary)
                    .frame(width: 5, height: 5)
                    .opacity(dotCount > index ? 1 : 0.2)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                dotCount = (dotCount + 1) % 4
            }
        }
    }
}
