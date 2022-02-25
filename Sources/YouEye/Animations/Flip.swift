import SwiftUI
import Commons

extension View {
    public func spin(duration: Double = 2.4) -> some View {
        self.modifier(Flip(duration: duration, axis: .z))
    }
}

extension View {
    public func flip(duration: Double = 2.4, axis: Flip.Axis = .x) -> some View {
        self.modifier(Flip(duration: duration, axis: axis))
    }
}


public struct Flip: AnimatableModifier {
    public enum Axis {
        case x, y, z
        
        fileprivate var tuple: (CGFloat, CGFloat, CGFloat) {
            switch self {
            case .x:
                return (1,0,0)
            case .y:
                return (0,1,0)
            case .z:
                return (0,0,1)
            }
        }
    }
    
    @State private var progress: Double = 0
    let duration: Double
    let axis: Axis
    
    public func body(content: Content) -> some View {
        return content
            .rotation3DEffect(.init(degrees: 360 * progress),
                              axis: axis.tuple,
                              perspective: 0)
            .onAppear {
                let anim = Animation
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                
                withAnimation(anim) {
                    progress = 1
                }
            }
    }
}

fileprivate struct FlipCarousel: View {
    @State private var axis: Flip.Axis = .x
    
    var body: some View {
        Rectangle()
            .fill(.red)
            .frame(width: 40, height: 40)
            .flip(axis: axis)
            .transition(.opacity)
            .onAppear(perform: change)
    }
    
    private func change() {
        switch axis {
        case .x:
            self.axis = .y
        case .y:
            self.axis = .z
        case .z:
            self.axis = .x
        }
        
        async.after(3, on: .main, execute: change)
    }
}

// Preview

struct FlipPreview: PreviewProvider {
    static var previews: some View {
        FlipCarousel()
            .frame(width: 200, height: 200)
    }
}
