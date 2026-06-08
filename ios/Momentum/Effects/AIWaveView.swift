import SwiftUI

struct AIWaveView: View {
    let color: Color
    let amplitude: Double
    let frequency: Double
    @State private var phase: Double = 0
    
    init(color: Color = .momentumTeal, amplitude: Double = 20, frequency: Double = 1.5) {
        self.color = color
        self.amplitude = amplitude
        self.frequency = frequency
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let midY = height / 2
                
                var path1 = Path()
                var path2 = Path()
                
                path1.move(to: CGPoint(x: 0, y: midY))
                path2.move(to: CGPoint(x: 0, y: midY))
                
                for x in stride(from: 0, through: width, by: 1) {
                    let relX = x / width
                    let y1 = midY + sin(relX * frequency * .pi * 4 + phase) * amplitude
                    let y2 = midY + sin(relX * frequency * .pi * 4 + phase * 1.3 + 1) * amplitude * 0.6
                    path1.addLine(to: CGPoint(x: x, y: y1))
                    path2.addLine(to: CGPoint(x: x, y: y2))
                }
                
                context.stroke(path1, with: .color(color.opacity(0.4)), lineWidth: 2)
                context.stroke(path2, with: .color(color.opacity(0.2)), lineWidth: 1.5)
            }
            .onChange(of: timeline.date) { _, _ in
                phase += 0.05
            }
        }
    }
}
