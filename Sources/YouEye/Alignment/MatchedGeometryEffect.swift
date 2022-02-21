import Foundation
import SwiftUI

@available(iOS 15, *)
struct MatchedGeometryExample: View {
    @Namespace private var matchyspace
    @State private var selected: Int = 1
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(0...3, id: \.self) { idx in
                    square(idx: idx, show: ==)
                }
            }
            HStack {
                square(idx: 0, show: !=)
                square(idx: 1, show: !=)
            }
            HStack {
                square(idx: 2, show: !=)
                square(idx: 3, show: !=)
            }
        }
        .frame(width: 200, height: 200)
        .buttonStyle(.testStyle)
    }
    
    @ViewBuilder func square(idx: Int, show: @escaping (Int, Int) -> Bool) -> some View {
        if show(selected, idx) {
            ZStack {
                palette[idx]
                Button("•") {
                    withAnimation {
                        self.selected = idx
                    }
                }
            }
            .matchedGeometryEffect(id: "sel.\(idx)",
                                   in: matchyspace)

        } else {
            Color.clear
        }
    }
}

@available(iOS 15, *)
struct MatchedGeometryEffectPreview: PreviewProvider {
    static var previews: some View {
        MatchedGeometryExample()
    }
}
