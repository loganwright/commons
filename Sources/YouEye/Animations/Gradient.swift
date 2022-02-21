import SwiftUI

public struct AnimatableGradient: View {
    public let from: [Color]
    public let to: [Color]
//    public var pct: CGFloat
    
    public var pct: CGFloat
//    {
//        get { pct }
//        set { pct = newValue }
//    }

    private var current: [Color] {
        zip(from, to).map { from, to in
            from.mix(with: to, percent: pct)
        }
    }

    public var body: some View {
        LinearGradient(
            gradient: Gradient(colors: current),
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: UnitPoint(x: 1, y: 1)
        )
        /// temporary to show that animating is working
        .scaleEffect(1 - (0.2 * pct))
    }
}


struct PassthroughModifier<Body: View>: AnimatableModifier {
    var animatableData: CGFloat
    let body: (CGFloat) -> Body
    
    func body(content: Content) -> some View {
        // also works to just pass body(animatableData)
        content.overlay(body(animatableData))
    }
}

fileprivate struct GradientExample: View, Animatable {
    @State var pct: CGFloat = 0
    
    private var base: some View {
        Rectangle()
            .fill(.black)
            .frame(width: 200, height: 100)
    }
    
    private func gradient(pct: CGFloat) -> some View {
        AnimatableGradient(from: [.orange, .red],
                           to: [.blue, .green],
                           pct: pct)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            base.overlay(
                gradient(pct: pct)
            )

            base.modifier(
                PassthroughModifier(animatableData: pct){ pct in
                    gradient(pct: pct)
                }
            )
        }
        .onAppear{
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: true)) {
                self.pct = pct == 0 ? 1 : 0
            }
        }
    }
}

struct GradientPreview: PreviewProvider {
    static var previews: some View {
        GradientExample()
    }
}
