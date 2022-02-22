import SwiftUI

struct DebugSizeDisplay: View {
    @State var size: CGSize
    
    var body: some View {
        ZStack {
            Color.clear
        }
    }
}
struct DebugSize: ViewModifier {
    @State private var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content.overlay(DebugSizeDisplay(size: size))
            .passGeometry { geo in
                self.size = geo.size
            }
    }
}
extension View {
    func debugSize() -> some View {
        self.modifier(DebugSize())
    }
}
