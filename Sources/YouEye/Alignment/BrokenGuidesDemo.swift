import SwiftUI
import Commons

struct Example: View {
    var body: some View {
        Text("hi")
    }
}

struct Hacky: ViewModifier {
    @Binding var scaleX: CGFloat
    let current: GeometryProxy
    let target: GeometryProxy
    
    /// outer * x == inner
    /// outer == inner / x
    func body(content: Content) -> some View {
//        DispatchQueue.main.async {
//            scaleX = 0.2
//
//        }
        print("current: \(current.size.width)")
        print("targeting: \(current.size.width)")
        print("scale.curr: \(scaleX)")
        print("scale.targ: \(current.size.width * scaleX)")
        scaleX = current.size.width / target.size.width
        return content
    }
}

extension View {
    func hackify(scaleX: Binding<CGFloat>, current: GeometryProxy, target: GeometryProxy) -> Self {
        let target = target.size.width / current.size.width
        DispatchQueue.main.async {
            scaleX.wrappedValue = target
        }
        return self
    }
}

extension View {
    func hackify(width: Binding<CGFloat?>, current: GeometryProxy, target: GeometryProxy) -> Self {
//        let scale = target.size.width / current.size.width
//        DispatchQueue.main.async {
//            width.wrappedValue = scale * current.size.width
//        }
//        let scale = target.size.width / current.size.width
        main {
            width.wrappedValue = target.size.width
        }
        print("t: \(target.size)")
        print("c: \(current.size)")
        return self
    }
}

extension View {
    func hackify(padding: Binding<CGFloat>, current: GeometryProxy, target: GeometryProxy) -> Self {
//        let scale = target.size.width / current.size.width
//        DispatchQueue.main.async {
//            width.wrappedValue = scale * current.size.width
//        }
//        let scale = target.size.width / current.size.width
        main {
            padding.wrappedValue = abs(current.size.width - target.size.width)
        }
        print("t: \(target.size)")
        print("c: \(current.size)")
        return self
    }
}

struct Broken: View {
//    @State private var scaleX: CGFloat = 1.0
    @State private var padding: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
//                Group {
                Capsule().fill(Color.red)
//                    .frame(width: width ?? geo.size.width)
                    .overlay(Rectangle().fill(palette[3]).frame(width: nil, height: 8))
                    .padding([.leading, .trailing], padding / 2)
                Capsule().fill(Color.green)
                    .overlay(
                        Circle().fill(.gray)
                            .frame(width: 20, height: 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    )
                    .padding([.leading, .trailing], padding / 2)
//                    .frame(width: width)
                Capsule().fill(Color.blue)
//                    .frame(width: width)
                    .alignmentGuide(.leading) { d in
                        //.alignmentGuide(HorizontalAlignment.center) { d in
                        d[HorizontalAlignment.leading] + 32// - 120
                    }
                    .overlay(Rectangle().fill(palette[3]).frame(height: 8))
                    .padding([.leading, .trailing], padding / 2)
//                    .overlay(
//                        ZStack {
//                            Color.orange // fill space
//                            Circle().fill(.gray).alignmentGuide(HorizontalAlignment.leading) { d in
//                                d[HorizontalAlignment.center]
//                            }
//                        }
//                    )
            }
            .overlay(
                GeometryReader { current in
                    Color.clear.hackify(padding: $padding, current: current, target: geo)
//                    Color.clear.hackify(width: $width, current: current, target: geo)
//                    Color.clear.hackify(scaleX: $scaleX, current: current, target: geo)
                }
            )
            .frame(width: geo.size.width)
            /// this isn't a good solution as it distorts the views :(
//            .scaleEffect(x: scaleX, anchor: .leading)
            .dashedOverlay(.red, 20)
        }
        .dashedOverlay(.blue)
        .padding(120)
    }
}

struct BrokenPreview: PreviewProvider {
    static var previews: some View {
        Broken()
    }
}

extension View {
    func dashedOverlay(_ color: Color, _ width: Double = 4) -> some View {
        self.overlay(DashedBorder(width: width).fill(color))
    }
}

struct DashedBorder: Shape {
    let width: Double
    func path(in rect: CGRect) -> Path {
        Path(rect).strokedPath(
            StrokeStyle(
                lineWidth: width,
                lineCap: .round,
                lineJoin: .bevel,
                miterLimit: 8,
                dash: [40, 20], //[8, 4, 4],
                dashPhase: 6
            )
        )
    }
}
