import SwiftUI

struct WeekBarChart: View {
    let values: [Double]
    let color: Color
    let labels: [String]
    let height: CGFloat
    
    init(values: [Double], color: Color, labels: [String] = ["M", "T", "W", "T", "F", "S", "S"], height: CGFloat = 120) {
        self.values = values
        self.color = color
        self.labels = labels
        self.height = height
    }
    
    private var maxVal: Double {
        max(values.max() ?? 1, 1)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                VStack(spacing: 6) {
                    let fraction = value / maxVal
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 28, height: max(fraction * height, 4))
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.05), value: values)
                    Text(labels[safe: index] ?? "")
                        .font(.momentumCaption)
                        .foregroundColor(.momentumTextTertiary)
                }
            }
        }
    }
}

struct MacroRingChart: View {
    let current: Double
    let goal: Double
    let color: Color
    let label: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(1, current / max(goal, 1)))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: current)
                VStack(spacing: 0) {
                    Text("\(Int(current))")
                        .font(.momentumCallout)
                        .foregroundColor(.white)
                    Text(unit)
                        .font(.momentumCaption)
                        .foregroundColor(.momentumTextTertiary)
                }
            }
            .frame(width: 64, height: 64)
            Text(label)
                .font(.momentumCaption)
                .foregroundColor(.momentumTextSecondary)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
