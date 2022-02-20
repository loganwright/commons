import SwiftUI

struct VGuideExample: View {
    
    let stackAlignment: Alignment
    let frameAlignment: Alignment
    var subviews: Int { alignmentNumberOfSubviews }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach(1...subviews, id: \.self) { idx in
                    palette[revolving: palette.count - 1 - idx]
                    
                        .frame(width: geo.size.width * 0.6,
                               height: geo.size.height / Double(subviews))
                }
                .background(palette[revolving: 3])
            }
            .frame(width: geo.size.width,
                   height: geo.size.height)
            .border(palette.first!, width: 4)
            .background(palette[revolving: 4])
            .padding([.top, .leading, .trailing, .bottom], 18)
        }
        .padding([.leading, .trailing], 10)
        .background(palette[2].opacity(0.8))
        .border(palette.first!)
        .frame(alignment: .center)
        //        .padding(12)
        
        //
        //        VStack(alignment: .leading, spacing: 0) {
        //            // ********
        //            ZStack(alignment: stackAlignment) {
        //                ForEach(1...subviews, id: \.self) { idx in
        //                    aligncolors[revolving: idx + colorOffset]
        //                        .frame(
        //                            width: stackSize.scaled(
        //                                forIdx: idx,
        //                                total: subviews
        //                            ).width,
        //                            height: stackSize.scaled(
        //                                forIdx: idx,
        //                                total: subviews
        //                            ).height
        //                        )
        //                }
        //            }
        //            .frame(
        //                width: stackSize.width,
        //                height: stackSize.height,
        //                alignment: frameAlignment
        //            )
        //            .border(aligncolors.first!)
        ////            .alignmentGuide(.leading) { d in
        ////                d[VerticalAlignment.center]
        ////            }
        //
        //            VStack(alignment: .leading) {
        //                Text("stack: ")
        //                    .alignStyled(size: 10)
        //                Text(stackAlignment.description)
        //                    .alignStyled(size: 12, .medium)
        //                Text("srame: ")
        //                    .alignStyled(size: 10)
        //                Text(frameAlignment.description)
        //                    .alignStyled(size: 12, .medium)
        //            }
        //            .frame(alignment: .leading)
        //            .padding(4)
        //        }
        //        .frame(alignment: .leading)
    }
}

struct NonGeo: View {
    var subviews: Int { alignmentNumberOfSubviews }
    
    let horizontal: HorizontalAlignment = .leading
    
    var body: some View {
        ZStack {
            VStack(alignment: horizontal, spacing: 0) {
                ForEach(1...subviews, id: \.self) { idx in
                    palette[revolving: palette.count - 1 - idx].opacity(0.32)
                    //                        .border(.pink, width: 8)
                    //                        .alignmentGuide(horizontal) { d in
                    //                            return 40
                    ////                            d[HorizontalAlignment.leading]
                    ////                            d[HorizontalAlignment.leading]
                    //                        }
                }
                .background(palette[revolving: 3])
                .border(palette[6], width: 10)
                //                .border(palette[6], width: 12)
                .overlay(
                    Rectangle()
                        .fill(palette.randomElement()!)
                        .border(.orange, width: 8)
                        .mask(Circle())
                )
                //                .zIndex(15)
            }
            //            .border(palette[7], width: 12)
            .border(palette.first!, width: 4)
            .background(palette[revolving: 4])
            .padding(18)
        }
        .background(palette[2].opacity(0.8))
        .border(palette[8], width: 3)
        .padding(20)
    }
}

extension View {
    func lockBounds() -> some View {
        //        Color.clear.background(self)
        GeometryReader { geo in
            self.frame(width: geo.width,
                       height: geo.size.height * 0.8)
                .position(x: geo.size.width / 2,
                          y: geo.size.height / 2)
        }
    }
}

extension GeometryProxy {
    var width: CGFloat {
        let global = frame(in: .global)
        if global.origin.x < 0 {
            return (size.width + global.origin.x) * 0.8
        } else {
            return size.width * 0.8
        }
    }
}

extension View {
    func apply(geo: GeometryProxy) -> some View {
        frame(width: geo.size.width, height: geo.size.height)
    }
    func apply(width: GeometryProxy) -> some View {
        frame(maxWidth: width.size.width)
    }
}

@available(iOS 15, *)
struct Doobbb: View {
    var subviews: Int { alignmentNumberOfSubviews }
    
    let horizontal: HorizontalAlignment = .trailing
    var alignment: Alignment { .init(
        horizontal: horizontal, vertical: .center)
    }
    
    var offset: CGFloat = 440
    
    var body: some View {
        GeometryReader { geo in
//            ZStack {
            VStack(alignment: horizontal, spacing: 0) {
                
                palette[8].mask(Capsule())
                palette[4]
                palette[6]
                palette[8]
                palette[9].alignmentGuide(horizontal) { d in
                    d[horizontal] - offset
                }
                
            }
            .padding(80)
            //                .overlay(Capsule().fill(palette[0]))
            .border(palette[0], width: 64)
            .scaleEffect(x: geo.size.width / (geo.size.width + offset), anchor: .leading)
//            .scaleEffect(x: (geo.size.width - offset) / geo.size.width, anchor: .leading)
                
//            }
//            .frame(width: geo.size.width)
//            .frame(maxWidth: geo.size.width)
//            .border(.orange)
            
//            .background(GeometryReader { geo in
//
//            })
//            .border(.purple, width: 40)
//            .apply(geo: geo)
//            .border(.green, width: 24)
        }
//        .background(palette[7].border(.cyan, width: 44))
//        .apply(geo: inner)
        //            .overlay(Color.pink)
        //            .border(.purple, width: 120)
//        .scaleEffect(x: (inner.size.width - offset) / inner.size.width)
        //            )
        //                    .frame(height: 80)
        //                    .frame(maxWidth: .infinity)
    }
    //        .border(.orange, width: 200)
        //                .frame(width: 200, height: 200)
        //                .border(.green, width: 4)
        //                .frame(width: geo.size.width, height: geo.size.height)
        
        //                }
        //            )
        
        //        VStack(alignment: horizontal, spacing: 0) {
        //            Group {
        //                palette[2].frame(width: 200, height: 40)
        //                    .alignmentGuide(horizontal) { d in
        ////                        -100
        //                        d[HorizontalAlignment.center]
        //                    }
        ////                    .layoutPriority(1)
        //                palette[4]
        //                palette[6]
        //                palette[8]
        //                //                .alignmentGuide(horizontal) { d in
        //                //                    d[HorizontalAlignment.center]
        //                //                }
        //                palette[9]
        //                //                .alignmentGuide(horizontal) { d in
        //                //                    d[HorizontalAlignment.center] + 180
        //                //                }
        //
        //            }
        //        }
        //        .overlay(
        //            Circle()
        //                .fill(.orange)
        //                .opacity(0.4)
        //        )
        //        .border(.black, width: 4)
        //        .lockBounds()
        ////        .clipped()
        ////        .fixedSize(horizontal: true, vertical: false)
        ////        .clipped()
        ////        .frame(width: 200, height: 200, alignment: .trailing)
        //        .border(.blue, width: 4)
        //        .padding()
//    }
}

struct AlignmentGuideDemo: View {
    var body: some View {
        Text("Alignment")
    }
}

extension View {
    func background(color: Color) -> some View {
        self.background(color)
    }
}

@available(iOS 15, *)
struct AlignmentGuidePreviews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                //                Text("..\(geo[])")
                Doobbb()
                //                    .frame(
                //                        width: geo.size.width * 0.5,
                //                        height: geo.size.height * 0.5
                //                    )
                VStack(alignment: .trailing) {
                    Text("geo.g \(geo.frame(in: .global).debugDescription)")
                    
                    Text("geo.l \(geo.frame(in: .local).debugDescription)")
                    
                }
                .font(.system(.largeTitle, design: .monospaced))
//                .frame(alignment: .bottomTrailing)
//                .border(.orange)
                
                //                Circle()
                //                    .fill(.black)
                //                //                    .stroke(palette[4], lineWidth: 8)
                //                //                    .frame(width: geo.size.width,
                //                //                           height: geo.size.height)
                //                    .frame(width: 200,
                //                           height: 400)
            }
            .apply(geo: geo)
//            .frame(alignment: .bottomTrailing)
            //            .border(.gray, width: 80)
            //            .overlayP
        }
        .background(color: .yellow.opacity(0.2))
        .border(.pink, width: 8)
        
        //        VGuideExample(
        //            stackAlignment: .center,
        //            frameAlignment: .center
        //        )
    }
}
