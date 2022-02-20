/// USING THIS AS A TEMPORARY STAGING FILE
import SwiftUI

public struct LoadingBar: AnimatableModifier {
    public var pct: CGFloat
    
    public var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(Bar(pct: pct, color: .orange))
    }
}

public struct PercentDriver<Overlay: View>: AnimatableModifier {
    public var pct: CGFloat
    let builder: (CGFloat) -> Overlay
    
    public var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }
    
    init(
        pct: CGFloat,
        _ builder: @escaping (CGFloat) -> Overlay) {
        self.pct = pct
        self.builder = builder
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(builder(pct))
    }
}

struct Bar: View {
    let pct: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Spacer()
            
            Rectangle()
                .fill(color)
                .frame(height: 4)
                .frame(maxWidth: .infinity)
                .scaleEffect(x: pct, anchor: .leading)
        }
    }
}

extension View {
    public func percentDriven<Content: View>(@ViewBuilder _ content: () -> Content) {
        fatalError()
    }
}

private struct Cont: View {
    @State private var pct = 0.0
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .frame(width: 240, height: 124)
                .border(.black)
                .modifier(LoadingBar(pct: pct))
            
            Button("START") {
                withAnimation(.linear(duration: 4.2)) {
                    pct = 1
                }
            }
        }
        
    }
}

struct PrevvyProvider: PreviewProvider {
    static var previews: some View {
        Cont()
    }
}
