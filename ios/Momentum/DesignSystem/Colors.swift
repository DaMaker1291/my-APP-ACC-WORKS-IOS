import SwiftUI

extension Color {
    static let momentumTeal = Color(hex: "#2DD4BF")
    static let momentumFocus = Color(hex: "#5E5CE6")
    static let momentumEnergy = Color(hex: "#FFD60A")
    static let momentumStress = Color(hex: "#FF453A")
    static let momentumRecovery = Color(hex: "#30D158")
    static let momentumBg = Color(hex: "#0A0A0F")
    static let momentumGlass = Color(white: 1.0, opacity: 0.03)
    static let momentumTextSecondary = Color(white: 1.0, opacity: 0.4)
    static let momentumTextTertiary = Color(white: 1.0, opacity: 0.25)
    static let momentumSurface = Color(white: 1.0, opacity: 0.05)
    static let momentumSurfaceLight = Color(white: 1.0, opacity: 0.08)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    static let momentumTeal = UIColor(red: 0x2D/255, green: 0xD4/255, blue: 0xBF/255, alpha: 1)
    static let momentumFocus = UIColor(red: 0x5E/255, green: 0x5C/255, blue: 0xE6/255, alpha: 1)
    static let momentumEnergy = UIColor(red: 0xFF/255, green: 0xD6/255, blue: 0x0A/255, alpha: 1)
    static let momentumStress = UIColor(red: 0xFF/255, green: 0x45/255, blue: 0x3A/255, alpha: 1)
    static let momentumRecovery = UIColor(red: 0x30/255, green: 0xD1/255, blue: 0x58/255, alpha: 1)
    static let momentumBg = UIColor(red: 0x0A/255, green: 0x0A/255, blue: 0x0F/255, alpha: 1)
}
