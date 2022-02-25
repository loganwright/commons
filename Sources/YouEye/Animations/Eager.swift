import SwiftUI
import Commons

/// a little eager to be pressed animation sequence
struct Eager: ViewModifier {
    private let outmax = CGFloat(1.04)
    private let innmin = CGFloat(1)
    @State private var duration = Double(0.08)
    @State private var value = CGFloat(1.0)
    
    private enum Direction: Equatable {
        case outgoing, incoming
    }
    @State private var direction = Direction.outgoing
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(y: value, anchor: .bottom)
            .animation(
                Animation.spring(
                    response: duration,
                    dampingFraction: 0.25,
                    blendDuration: duration),
                value: value
            )
            .onAppear {
                sequence { TimeInterval.random(in: (0.4...2.5)) }
            }
    }
    
    func sequence(delay: @escaping () -> TimeInterval) {
        async.after(delay()) {
            duration = Int.random(in: 0...5) < 3 ? 0.35 : 0.24
            value = outmax
            async.after(duration) {
                duration = Int.random(in: 0...5) < 3 ? 0.12 : 0.16
                value = innmin
                async.after(duration) {
                    sequence(delay: delay)
                }
            }
        }
    }
}

struct EagerPreview: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(.blue)
            .frame(width: 120, height: 320)
            .modifier(Eager())
    }
}
