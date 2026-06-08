import SwiftUI

extension Font {
    static let momentumLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let momentumTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let momentumTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let momentumTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let momentumHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let momentumBody = Font.system(size: 15, weight: .regular, design: .rounded)
    static let momentumCallout = Font.system(size: 14, weight: .medium, design: .rounded)
    static let momentumSubheadline = Font.system(size: 13, weight: .medium, design: .rounded)
    static let momentumFootnote = Font.system(size: 12, weight: .regular, design: .rounded)
    static let momentumCaption = Font.system(size: 10, weight: .medium, design: .rounded)
    static let momentumMono = Font.system(size: 15, weight: .regular, design: .monospaced)
}

extension Text {
    func momentumLargeTitle() -> some View {
        self.font(.momentumLargeTitle)
    }
    func momentumTitle() -> some View {
        self.font(.momentumTitle)
    }
    func momentumTitle2() -> some View {
        self.font(.momentumTitle2)
    }
    func momentumTitle3() -> some View {
        self.font(.momentumTitle3)
    }
    func momentumHeadline() -> some View {
        self.font(.momentumHeadline)
    }
    func momentumBody() -> some View {
        self.font(.momentumBody)
    }
    func momentumCallout() -> some View {
        self.font(.momentumCallout)
    }
    func momentumSubheadline() -> some View {
        self.font(.momentumSubheadline)
    }
    func momentumFootnote() -> some View {
        self.font(.momentumFootnote)
    }
    func momentumCaption() -> some View {
        self.font(.momentumCaption)
    }
}
