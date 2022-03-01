import SwiftUI
import Commons

extension View {
    public func dashedBorder(_ color: Color = .red, _ width: Double = 2) -> some View {
        self.overlay(DashedBorder(width: width).fill(color))
    }
}

//

struct DebugSizeDisplay: View {
    @Binding var size: CGSize
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.clear
            Text("w: \(Double(size.width).limitPlaces(to: 1)), h: \(Double(size.height).limitPlaces(to: 1))")
                .commonStyle(size: 24, .bold)
        }
    }
}

struct DebugSize: ViewModifier {
    @State private var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
        .overlay(DebugSizeDisplay(size: $size))
        .passGeometry { geo in
            self.size = geo.size
        }
    }
}

extension View {
    func debuggable() -> some View {
        self.dashedBorder(.red, 4)
            .debugSize()
    }
    
    func debugSize() -> some View {
        self.modifier(DebugSize())
    }
}

struct DebugExample: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(1...20, id: \.self) { idx in
                    palette[revolving: idx]
                        .frame(height: 120)
                        .debuggable()
                }
            }
        }
    }
}
struct DebuasdfgPreviews: PreviewProvider {
    static var previews: some View {
        DebugExample()
    }
}
