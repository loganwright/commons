import SwiftUI

extension View {
    /// inverse mask:
    /// https://www.raywenderlich.com/7589178-how-to-create-a-neumorphic-design-with-swiftui
    public func inverseMask<Mask>(_ mask: Mask) -> some View where Mask: View {
        self.mask(
            mask
                .foregroundColor(.black)
                .background(Color.white)
                .compositingGroup()
                .luminanceToAlpha()
        )
    }
}
