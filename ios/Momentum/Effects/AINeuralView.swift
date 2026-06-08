import SwiftUI

struct AINeuralView: View {
    let nodeCount: Int
    let color: Color
    @State private var phase: Double = 0
    
    struct NeuralNode: Identifiable {
        let id = UUID()
        var x: Double
        var y: Double
        var size: Double
        var opacity: Double
    }
    
    init(nodeCount: Int = 12, color: Color = .momentumFocus) {
        self.nodeCount = nodeCount
        self.color = color
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let nodes = generateNodes(for: size)
                for node in nodes {
                    let rect = CGRect(x: node.x - node.size / 2, y: node.y - node.size / 2, width: node.size, height: node.size)
                    let path = Circle().path(in: rect)
                    context.fill(path, with: .color(color.opacity(node.opacity)))
                }
                // Draw connections
                for i in 0..<nodes.count {
                    for j in (i+1)..<nodes.count {
                        let dist = hypot(nodes[i].x - nodes[j].x, nodes[i].y - nodes[j].y)
                        if dist < 100 {
                            var path = Path()
                            path.move(to: CGPoint(x: nodes[i].x, y: nodes[i].y))
                            path.addLine(to: CGPoint(x: nodes[j].x, y: nodes[j].y))
                            let opacity = (1 - dist / 100) * 0.2
                            context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: 0.5)
                        }
                    }
                }
            }
            .onChange(of: timeline.date) { _, _ in
                phase += 0.02
            }
        }
        .ignoresSafeArea()
    }
    
    private func generateNodes(for size: CGSize) -> [NeuralNode] {
        let layers = 4
        let nodesPerLayer = nodeCount / layers
        var nodes: [NeuralNode] = []
        for layer in 0..<layers {
            for i in 0..<nodesPerLayer {
                let x = (Double(layer) + 0.5) / Double(layers) * size.width
                let y = (Double(i) + 0.5) / Double(nodesPerLayer) * size.height
                let offset = sin(phase + Double(layer) * 0.5 + Double(i) * 0.3) * 5
                nodes.append(NeuralNode(
                    x: x + offset,
                    y: y + sin(phase * 0.7 + Double(i) * 0.5) * 5,
                    size: Double.random(in: 3...6),
                    opacity: Double.random(in: 0.3...0.7)
                ))
            }
        }
        return nodes
    }
}
