import SwiftUI

struct BreathingParticleRing: View {
    @Binding var phase: BreathingPhase
    @State private var particles: [RingParticle] = []
    let color: Color
    
    struct RingParticle: Identifiable {
        let id = UUID()
        var angle: Double
        var distance: Double
        var size: Double
        var opacity: Double
        var speed: Double
    }
    
    enum BreathingPhase {
        case inhale, hold, exhale, rest
        
        var duration: Double {
            switch self {
            case .inhale: return 4
            case .hold: return 4
            case .exhale: return 6
            case .rest: return 2
            }
        }
        
        var next: BreathingPhase {
            switch self {
            case .inhale: return .hold
            case .hold: return .exhale
            case .exhale: return .rest
            case .rest: return .inhale
            }
        }
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let scale: Double = {
                    switch phase {
                    case .inhale: return 1.0
                    case .hold: return 0.95
                    case .exhale: return 0.6
                    case .rest: return 0.5
                    }
                }()
                
                for particle in particles {
                    let angleRad = particle.angle * .pi / 180
                    let dist = particle.distance * scale * min(size.width, size.height) / 2.5
                    let x = center.x + cos(angleRad) * dist
                    let y = center.y + sin(angleRad) * dist
                    let rect = CGRect(x: x - particle.size / 2, y: y - particle.size / 2, width: particle.size, height: particle.size)
                    let path = Circle().path(in: rect)
                    context.fill(path, with: .color(color.opacity(particle.opacity)))
                }
                
                // Center circle
                let centerRect = CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)
                context.fill(Circle().path(in: centerRect), with: .color(color.opacity(0.5)))
            }
            .onChange(of: timeline.date) { _, _ in
                updateParticles()
            }
            .onAppear {
                initializeParticles()
                startBreathingCycle()
            }
        }
    }
    
    private func initializeParticles() {
        particles = (0..<24).map { i in
            RingParticle(
                angle: Double(i) * 15,
                distance: Double.random(in: 0.3...0.8),
                size: Double.random(in: 2...5),
                opacity: Double.random(in: 0.2...0.6),
                speed: Double.random(in: 0.5...1.5)
            )
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].angle += particles[i].speed * 0.5
            if particles[i].angle > 360 { particles[i].angle -= 360 }
            particles[i].opacity = 0.3 + sin(particles[i].angle * .pi / 180) * 0.2
        }
    }
    
    private func startBreathingCycle() {
        Task {
            while true {
                try? await Task.sleep(nanoseconds: UInt64(phase.duration * 1_000_000_000))
                await MainActor.run {
                    withAnimation(.easeInOut(duration: phase.duration)) {
                        phase = phase.next
                    }
                }
            }
        }
    }
}
