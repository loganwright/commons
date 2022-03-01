import SwiftUI

struct AlignmentIndicator: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            
            Rectangle().fill(.blue).frame(width: 8)
        }
    }
}

extension HorizontalAlignment {
    private enum MyAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[.trailing]
        }
    }
    static let myAlignment = HorizontalAlignment(MyAlignment.self)
}

extension AnyTransition {
    static var iris: AnyTransition {
//        .modifier(active: <#T##ViewModifier#>, identity: <#T##ViewModifier#>)
        fatalError()
//        .modifier(
//            active: ClipShapeModifier(shape: ScaledCircle(animatableData: 0)),
//            identity: ClipShapeModifier(shape: ScaledCircle(animatableData: 1))
//        )
    }
}

struct DetectAlignment: View {
    @Binding var horiontal: HorizontalAlignment
    
    var body: some View {
//        VStack(alignment: .trailing) {
        ZStack(alignment: .trailing) {
            Color.green
//                .frame(width: 90, height: 90)
//                .overlay(Text("H.AG \(horiontal.asString)").commonStyle(size: 14, .heavy))
            
            Color.red.frame(width: 20, height: 20)
//                .when(parent: .center, use: .center)
//                .when(parent: .leading, use: .center)
//                .when(parent: .trailing, use: .center)
        }
        .frame(maxWidth: nil, alignment: .trailing)
//            .frame(width: 200, height: 100)
//            .horizontal(.leading, upstream: $horiontal)
//            .horizontal(.center, upstream: $horiontal)
//            .horizontal(.trailing, upstream: $horiontal)
//            .overlay(            Color.yellow.frame(width: 20, height: 20)
//                                    .when(parent: .center, use: .center)
//                                    .when(parent: .leading, use: .center)
//                                    .when(parent: .trailing, use: .center))
            .dashedBorder()
//            .frame(alignment: .topTrailing)
//            .alignmentGuide(.trailing) { d in
//                self.horiontal = .trailing
//                return d[.trailing]
//            }
//        }
    }
}

extension View {
    func horizontal(_ alignment: HorizontalAlignment, upstream: Binding<HorizontalAlignment>) -> some View {
        self.alignmentGuide(alignment) { d in
            upstream.wrappedValue = alignment
//            return 0//
            return d[alignment]
        }
    }
    
    func when(parent: HorizontalAlignment, use: HorizontalAlignment) -> some View {
        self.alignmentGuide(parent) { d in
            d[use]
        }
    }
}

//struct All
//@available(iOS 15, *)
struct AlignmentGuidesExample: View {
    @State private var msgs = "<n>"
    
    @State private var alignment: HorizontalAlignment = .leading
    
    @State private var aaaa: HorizontalAlignment = .leading
    var body: some View {
//        GeometryReader { geo in
//            Text(msgs).commonStyle(size: 24, .heavy).background(Color.white)
//                .frame(height: 40)
//                .offset(x: 40, y: 40)
        VStack(alignment: .myAlignment) {
                Text("\(aaaa.asString)").commonStyle(size: 20, .thin)
                DetectAlignment(horiontal: $aaaa)
                .alignmentGuide(.myAlignment) { d in
//                    d[HorizontalAlignment.center]
                    d[.trailing]
                }
//                    .horizontal(.trailing, upstream: $aaaa)
                Circle().fill(.orange)
                    .frame(width: 200, height: 60)
                    .dashedBorder(.yellow)
                ZStack {
                    Rectangle()
                        .fill(palette[0])
                        .frame(width: 60)
                        .dashedBorder(.blue)
                    //                    .padding()
                    
                }
                .frame(height: 60)
                .dashedBorder()
                //            .padding(8)
                
                Group {
                    palette[1]
                    //                    .alignmentGuide(alignment) { d in
                    //
                    //                    }
                    palette[2]
                    palette[3]
//                    ZStack {
                    palette[4]
                    Circle()
                        .frame(width: 20, height: 20)
//                        .position(x: 40, y: 0)
//                    }
                }
//                .padding(20)
                .frame(width: 100, height: 44)
                .alignmentGuide(.myAlignment, computeValue: { d in
                    d[.leading]
                })
                .dashedBorder(.blue, 8)
//                .padding(8)
                .dashedBorder(.purple)
                
                //            ForEach(1...4, id: \.self) { idx in
                //                palette[revolving: idx]
                ////                    .alignmentGuide(alignment) { d in
                ////                        var hey = ""
                //////                        hey += d[explicit: .top]?.description ?? "<> \(idx) "
                ////
                ////                        hey += "\n"
                ////                        hey += d[HorizontalAlignment.center].description ?? "<>"
                ////                        msgs = hey
                ////                        return d.width / CGFloat(idx)
                ////                    }
                //            }
                //            .padding(20)
                //            .dashedBorder(.blue, 8)
                //            .padding(28)
                //            .dashedBorder(.purple)
            }
            //            .frame(alignment: .top)
            .dashedBorder(.red, 8)
            .padding(20)
//            .frame(alignment: .topLeading)
            .dashedBorder(.pink, 12)
//            .frame(width: geo.size.width * 0.8,
//                   height: geo.size.height * 0.8,
//                   alignment: .center)
//            .dashedBorder(.black, 20)
//            .offset(x: (geo.size.width * 0.2) / 2, y: (geo.size.height * 0.2) / 2)
//        }
//        .dashedBorder(.orange, 40)
    }
    
}

@available(iOS 15, *)
struct AlignmentGuidePreviews: PreviewProvider {
    static var previews: some View {
        AlignmentGuidesExample()
//            .frame(alignment: .leading)
            .dashedBorder(.green, 8)
            .padding(200)
    }
}
