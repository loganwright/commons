import SwiftUI

public struct Spin: AnimatableModifier {
    @State private var progress: Double = 0
    
    public func body(content: Content) -> some View {
        return content
            .rotationEffect(.init(degrees: 360 * progress))
            .onAppear {
                let anim = Animation.linear(duration: 4)
                    .repeatForever(autoreverses: false)
                
                withAnimation(anim) {
                    progress = 1
                }
            }
    }
}

extension View {
    public func spin() -> some View {
        self.modifier(Spin())
    }
}

public struct AnimatableGradient: AnimatableModifier {
    public let from: [Color]
    public let to: [Color]
    public var pct: CGFloat
    
    public var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }
    
    public func body(content: Content) -> some View {
        var gColors = [Color]()
        
        for i in 0..<from.count {
            gColors.append(colorMixer(c1: from[i], c2: to[i], pct: pct))
        }
        
        return RoundedRectangle(cornerRadius: 15)
            .fill(LinearGradient(gradient: Gradient(colors: gColors),
                                 startPoint: UnitPoint(x: 0, y: 0),
                                 endPoint: UnitPoint(x: 1, y: 1)))
            .frame(width: 200, height: 200)
    }
    
    // This is a very basic implementation of a color interpolation
    // between two values.
    func colorMixer(c1: Color, c2: Color, pct: CGFloat) -> Color {
        guard let cc1 = c1.cgColor?.components else { return c1 }
        guard let cc2 = c2.cgColor?.components else { return c1 }
        
        let r = (cc1[0] + (cc2[0] - cc1[0]) * pct)
        let g = (cc1[1] + (cc2[1] - cc1[1]) * pct)
        let b = (cc1[2] + (cc2[2] - cc1[2]) * pct)

        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
}
