import SwiftUI

enum MomentumTab: String, CaseIterable {
    case today = "Today"
    case reels = "Reels"
    case nutrition = "Nutrition"
    case coach = "Coach"
    case focus = "Focus"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .today: return "circle.grid.2x2"
        case .reels: return "play.rectangle"
        case .nutrition: return "fork.knife"
        case .coach: return "brain.head.profile"
        case .focus: return "timer"
        case .profile: return "person.circle"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .today: return "circle.grid.2x2.fill"
        case .reels: return "play.rectangle.fill"
        case .nutrition: return "fork.knife.circle.fill"
        case .coach: return "brain.head.profile.fill"
        case .focus: return "timer.circle.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

struct MomentumTabBar: View {
    @Binding var selectedTab: MomentumTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MomentumTab.allCases, id: \.self) { tab in
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 22))
                        .foregroundColor(selectedTab == tab ? .white : .momentumTextSecondary)
                        .frame(height: 24)
                    Text(tab.rawValue)
                        .font(.momentumCaption)
                        .foregroundColor(selectedTab == tab ? .white : .momentumTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.bottom, 8)
        .background(Color.momentumBg)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5)
        }
    }
}
