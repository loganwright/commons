import SwiftUI
//struct RollTransition: ViewModifier {
//    let degrees: Double
//    func body(content: Content) -> some View {
//        content.rotationEffect(Angle(degrees: degrees))
//    }
//}
//

struct SpinTransition: ViewModifier {
    let scale: CGFloat
    func body(content: Content) -> some View {
        content.scaleEffect(scale)
    }
}

extension AnyTransition {
    static var alt_spinIn: AnyTransition {
        .modifier(
            active: RollTransition(degrees: -(360 * 1)),
            identity: RollTransition(degrees: 0)
        )
    }
    static var zoom: AnyTransition {
        .modifier(
            active: SpinTransition(scale: 0.01),
            identity: SpinTransition(scale: 1)
        )
    }
}

struct TransitionTest: View {
    @State private var show = false
    var body: some View {
        VStack {
            if show {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 80, height: 80)
//                    .offset(y: -120)
//                    .transition(.zoom.combined(with: .alt_spinIn).combined(with: .opacity).animation(.linear))
                
                    .transition(.zoom.combined(with: .alt_spinIn).combined(with: .opacity).animation(.linear))
//                    .transition(.alt_spinIn.animation(.linear))
//                    .animation(.linear, value: show)
//                    .transition(.opacity)
//                    .transition(.scale(scale: 0.5, anchor: .topLeading).animation(.linear))
            }
            
            Button {
//                withAnimation(.linear) {
                    show.toggle()
//                }
            } label: {
                Text("run")
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .animation(.linear)
            .transition(.slide)
//            .transition(.slide.animation(.linear))
            //        .animation(.linear)
        }
//        .animation(.linear, value: show)
    }
}

struct TransitionTest_Previews: PreviewProvider {
    static var previews: some View {
        TransitionTest()
    }
}
