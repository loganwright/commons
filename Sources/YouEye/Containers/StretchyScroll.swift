import SwiftUI

/// allows the scrollview to stretch to accomodate the content if possible
public struct StretchyScrollView<Content> : View where Content : View {
    public var content: Content
    public var axes: Axis.Set
    public var showsIndicators: Bool

    @State private var contentSize: CGSize = .zero
    
    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.axes = axes
        self.showsIndicators = showsIndicators
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content.frame(maxWidth: .infinity).padding(0).passGeometry { geo in
                contentSize = geo.size
            }
        }
        .frame(
            maxWidth: axes.contains(.horizontal)
            ? contentSize.height : .infinity,
            maxHeight: axes.contains(.vertical)
            ? contentSize.height : .infinity
        )
    }
}
