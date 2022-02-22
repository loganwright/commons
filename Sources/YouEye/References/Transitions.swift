import SwiftUI

struct RollTransition: ViewModifier {
    let degrees: Double
    func body(content: Content) -> some View {
        content.rotationEffect(Angle(degrees: degrees))
    }
}

extension AnyTransition {
    static var spinIn: AnyTransition {
        .modifier(
            active: RollTransition(degrees: -(360 * 8)),
            identity: RollTransition(degrees: 0)
        )
    }
}

extension AnyTransition {
    static var myOpacity: AnyTransition { get {
        AnyTransition.modifier(
            active: MyOpacityModifier(opacity: 0),
            identity: MyOpacityModifier(opacity: 1))
        }
    }
}

struct MyOpacityModifier: ViewModifier {
    let opacity: Double
    
    func body(content: Content) -> some View {
        content.opacity(opacity)
    }
}


struct TransitionExample: View {
    @State var showing: Bool = false
    var body: some View {
        VStack {
            ZStack {
                Color.clear
                if showing {
                    ZStack {
                        palette.randomElement()!
                    }.transition(.spinIn)
                }
            }
            
            Button {
                withAnimation {
            
                    showing.toggle()
                }
            } label: {
                Text("ENTER")
            }
        }
        .buttonStyle(.testStyle)
    }
}

struct TransitionRefPrev: PreviewProvider {
    static var previews: some View {
        TransitionExample()
    }
}
