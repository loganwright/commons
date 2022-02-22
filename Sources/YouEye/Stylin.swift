import SwiftUI

extension View {
    func commonStyle(size: CGFloat = 14, _ weight: Font.Weight = .light) -> some View {
        self.font(.system(size: size, weight: weight, design: .monospaced))
    }
}
