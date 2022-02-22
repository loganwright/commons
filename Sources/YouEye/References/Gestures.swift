import SwiftUI

public struct Zooming: ViewModifier {
    public let max: CGFloat
    @State
    private var zoom: CGFloat = 1
    
    public func body(content: Content) -> some View {
        
//        StretchyScrollView(.horizontal) {
            content
                .scaleEffect(zoom)
        .gesture(
            MagnificationGesture()
                .onChanged({ new in
                    self.zoom = new
                })
                .onEnded({ new in
                    self.zoom = new
                })
        )
    }
}
//
//extension View {
//    func gesture<G: Gesture>(_ gsture: () -> G) -> some View {
//        self.gesture(gesture())
//    }
//}

struct Draggable: ViewModifier {
    @GestureState private var drag: DragGesture.Value?
    var touches: Int = 1
    
    func body(content: Content) -> some View {
        content
            .offset(drag?.translation ?? .zero)
            .simultaneousGesture(
                DragGesture()
                    .updating($drag) { current, state, transaction in
                        state = current
                    }
            )
            .animation(.linear, value: drag)
    }
}

struct RotateableModifier: ViewModifier {
    @GestureState private var rotation: Angle = .zero
    
    func body(content: Content) -> some View {
        content
        .rotationEffect(rotation)
        .simultaneousGesture(
            RotationGesture()
                .updating($rotation) { current, state, transaction in
                    state = current
                    transaction.disablesAnimations = true
                }
        )
        .animation(.linear, value: rotation)
    }
}
struct ZoomModifier: ViewModifier {
    @GestureState var zoom = 1.0
    @State private var meta: String = "<>"
    func asdfasfd() {
//        return ""
    }
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($zoom) { currentState, gestureState, transaction in
                gestureState = currentState
                transaction.disablesAnimations = true
                var _meta = "\(transaction)"
                _meta += "anim: \(transaction.animation != nil)"
                _meta += "\ncts: \(transaction.isContinuous)"
                _meta += "\ndisables: \(transaction.disablesAnimations)"
                meta = _meta
            }
    }
    
    func body(content: Content) -> some View {
        content
//        Circle()
//            .frame(width: 100, height: 100)
            .scaleEffect(zoom)
            .simultaneousGesture(magnification)
            .background(
                VStack {
                    Text("zm: \(zoom.limitPlaces(to: 2))")
                        .commonStyle(size: 40)
                    Text(meta)
                        .commonStyle(size: 12)
                }
                .offset(y: 100)
            )
            .animation(.linear, value: zoom)
    }
}

extension View {
    func zoomable(max: CGFloat) -> some View {
        self.modifier(ZoomModifier())
    }
    func rotateale() -> some View {
        self.modifier(RotateableModifier())
    }
    func draggable() -> some View {
        self.modifier(Draggable())
    }
}

struct GesturesExample: View {
    var body: some View {
        
        Text("hi")
            .commonStyle(size: 120)
            .frame(width: 200, height: 120)
            .dashedBorder()
    }
}

struct ZoomPreviews: PreviewProvider {
    static var previews: some View {
        GesturesExample()
            .zoomable(max: 8)
            .rotateale()
            .draggable()
    }
}
