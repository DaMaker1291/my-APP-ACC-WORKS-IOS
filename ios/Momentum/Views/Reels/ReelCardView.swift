import SwiftUI

struct ReelCardView: View {
    let scored: ScoredReel
    let isActive: Bool
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: scored.reel.colorHex).opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: scored.reel.iconName)
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: scored.reel.colorHex))
                }
                
                // Title
                VStack(spacing: 8) {
                    Text(scored.reel.title)
                        .font(.momentumTitle)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(scored.reel.description)
                        .font(.momentumBody)
                        .foregroundColor(.momentumTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Category + Duration
                HStack(spacing: 16) {
                    Label(scored.reel.category.rawValue, systemImage: "tag")
                        .font(.momentumCaption)
                        .foregroundColor(Color(hex: scored.reel.colorHex))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: scored.reel.colorHex).opacity(0.1))
                        .cornerRadius(8)
                    
                    Label("\(Int(scored.reel.duration / 60)) min", systemImage: "clock")
                        .font(.momentumCaption)
                        .foregroundColor(.momentumTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.momentumGlass)
                        .cornerRadius(8)
                }
                
                // Science Note
                MomentumCard {
                    HStack {
                        Image(systemName: "flask")
                            .foregroundColor(.momentumFocus)
                            .font(.caption)
                        Text(scored.reel.scienceNote)
                            .font(.momentumCaption)
                            .foregroundColor(.momentumTextSecondary)
                    }
                }
                .padding(.horizontal, 40)
                
                // Reason
                Text(scored.reason)
                    .font(.momentumCaption)
                    .foregroundColor(.momentumTextTertiary)
                
                Spacer()
                
                // Swipe hint
                if isActive {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.up")
                            .font(.caption)
                        Text("Swipe up for next")
                            .font(.momentumCaption)
                    }
                    .foregroundColor(.momentumTextTertiary)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
