import SwiftUI

struct ScoreRing: View {
    let progress: Double
    let color: Color
    let strokeWidth: CGFloat
    let label: String?
    let showText: Bool
    
    init(progress: Double, color: Color, strokeWidth: CGFloat = 8, label: String? = nil, showText: Bool = true) {
        self.progress = max(0, min(1, progress))
        self.color = color
        self.strokeWidth = strokeWidth
        self.label = label
        self.showText = showText
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: strokeWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: progress)
            if showText {
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))")
                        .font(.momentumTitle2)
                        .foregroundColor(.white)
                    if let label = label {
                        Text(label)
                            .font(.momentumCaption)
                            .foregroundColor(.momentumTextSecondary)
                    }
                }
            }
        }
    }
}

struct TinyScoreRing: View {
    let progress: Double
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: progress)
                Text("\(Int(progress * 100))")
                    .font(.momentumCaption)
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
            Text(label)
                .font(.momentumCaption)
                .foregroundColor(.momentumTextSecondary)
        }
    }
}
