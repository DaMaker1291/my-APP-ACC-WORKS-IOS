import SwiftUI

struct AIParticleView: View {
    @State private var particles: [Particle] = []
    let color: Color
    let count: Int
    
    init(color: Color = .momentumTeal, count: Int = 30) {
        self.color = color
        self.count = count
    }
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: Double
        var y: Double
        var scale: Double
        var opacity: Double
        var speed: Double
        var size: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x * size.width,
                        y: particle.y * size.height,
                        width: particle.size,
                        height: particle.size
                    )
                    let path = Circle().path(in: rect)
                    context.fill(path, with: .color(color.opacity(particle.opacity)))
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateParticles()
            }
            .onAppear {
                initializeParticles()
            }
        }
        .ignoresSafeArea()
    }
    
    private func initializeParticles() {
        particles = (0..<count).map { _ in
            Particle(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                scale: Double.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.1...0.5),
                speed: Double.random(in: 0.002...0.008),
                size: Double.random(in: 2...6)
            )
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].y -= particles[i].speed
            particles[i].x += sin(particles[i].y * 10) * 0.003
            particles[i].opacity = max(0.05, particles[i].opacity - 0.001)
            if particles[i].y < 0 || particles[i].opacity < 0.05 {
                particles[i].y = 1.0
                particles[i].x = Double.random(in: 0...1)
                particles[i].opacity = Double.random(in: 0.2...0.6)
                particles[i].size = Double.random(in: 2...6)
            }
        }
    }
}
