import SwiftUI

struct TestButtonStyle: ButtonStyle {
    @ViewBuilder func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fillParentBounds()
            .contentShape(Rectangle())
            .border(.black)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == TestButtonStyle {
    static var testStyle: TestButtonStyle {
        TestButtonStyle()
    }
}
