#if !os(tvOS)
import SwiftUI

/// use `view.onTapGesture` as you normally would
/// adding an argument will respond with the
/// touche's location
struct TapWithLocation: ViewModifier {
    public let response: (CGPoint) -> Void
    @State private var location: CGPoint = .zero
    
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                response(location)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { location = $0.location }
            )
    }
}

extension View {
    public func onTapGesture(_ handler: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(TapWithLocation(response: handler))
    }
}
#endif
