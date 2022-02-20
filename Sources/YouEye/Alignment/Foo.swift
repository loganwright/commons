import SwiftUI

extension VerticalAlignment {
    private enum MyAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[.bottom]
        }
    }
    static let myAlignment = VerticalAlignment(MyAlignment.self)
}

struct CustomView: View {
    @State private var selectedIdx = 1
    
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
            HStack(alignment: .myAlignment) {
                Image(systemName: "arrow.right.circle.fill")
                    .alignmentGuide(.myAlignment, computeValue: { d in d[VerticalAlignment.center] + 100 })
                    .foregroundColor(.green)

                VStack(alignment: .leading) {
                    ForEach(days.indices, id: \.self) { idx in
                        Group {
                            if idx == self.selectedIdx {
                                Text(self.days[idx])
                                    .transition(AnyTransition.identity)
                                    .alignmentGuide(.myAlignment, computeValue: { d in d[VerticalAlignment.center] + 20 })
                            } else {
                                Text(self.days[idx])
                                    .transition(AnyTransition.identity)
                                    .onTapGesture {
                                        withAnimation {
                                            self.selectedIdx = idx
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .font(.largeTitle)
            .border(.black)
    }
}

struct LKJHKLJHLK: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .trailing) {
            GeometryReader { geo in
                Rectangle()
                    .fill(palette[4])
                    .frame(width: geo.size.width * 0.8)
                Text("hello")
            }
            .frame(alignment: .center)
            .background(Color.blue)
            .border(.green, width: 19)
            
            Text("sadfasdfsafd")
//            HStack(alignment: .tex)
            
//            Ellipse()
//                .fill(Color.purple)
//                .aspectRatio(0.75, contentMode: .fill)
//                .frame(width: 200, height: 200)
//                .border(Color(white: 0.75))
        }
        .background(Color.yellow)
    }
}
