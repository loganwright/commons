import SwiftUI

extension Color {
    public init(hex: String) {
        guard hex.hasPrefix("#"), hex.count == 7 else {
            fatalError("unexpected hex color format")
        }

        let cleanHex = hex.uppercased()
        let chars = Array(cleanHex)
        let rChars = chars[1...2]
        let gChars = chars[3...4]
        let bChars = chars[5...6]

        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0;
        Scanner(string: .init(rChars)).scanHexInt64(&r)
        Scanner(string: .init(gChars)).scanHexInt64(&g)
        Scanner(string: .init(bChars)).scanHexInt64(&b)
        self = Color(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0
        )
    }
}

fileprivate var palette: [String] = [
    "#5C4B51",
    "#8CBEB2",
    "#F2EBBF",
    "#F3B562",
    "#F06060",
]

/// harmony colors, pairing w palette
fileprivate var counterPalette: [String] = [
    "#4b5c56",
    "#8cbeb2",
    "#bfc6f2",
    "#62a0f3",
    "#60f0f0",
]

fileprivate var aligncolors: [Color] = (palette + counterPalette).map(Color.init)


/// stack alignment - aligns subviews internally
/// frame alignment - aligns the content WITHIN self (if content smaller than self)


extension CGSize {
    func scaled(forIdx idx: Int, total: Int) -> CGSize {
        let wSegments = width / (Double(total) * 1.2)
        let w = width - (wSegments * Double(idx))
        
        let hSegments = height / (Double(total) * 1.2)
        let h = width - (hSegments * Double(idx))
        return CGSize(width: w, height: h)
    }
    
}

extension Alignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bottom: return "bottom"
        case .bottomLeading: return "bottomLeading"
        case .bottomTrailing: return "bottomTrailing"
        case .center: return "center"
        case .leading: return "leading"
        case .top: return "top"
        case .topLeading: return "topLeading"
        case .topTrailing: return "topTrailing"
        case .trailing: return "trailing"
        default: return "unknown alignment"
        }
    }
}

let alignmentExampleSize = CGSize(width: 120, height: 120)
var inner: CGSize {
    .init(width: alignmentExampleSize.width * 0.72,
          height: alignmentExampleSize.height * 0.72
    )
}

struct ZExample: View {
    let stackAlignment: Alignment
    let frameAlignment: Alignment
    var numberOfSubViews: Int = 4
    var size = alignmentExampleSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: stackAlignment) {
                ForEach(1...numberOfSubViews, id: \.self) { idx in
                    aligncolors[idx + 1]
                        .frame(
                            width: inner.scaled(forIdx: idx, total: numberOfSubViews).width,
                            height: inner.scaled(forIdx: idx, total: numberOfSubViews).height
                        )
                }
            }
            .frame(
                width: size.width,
                height: size.height,
                alignment: frameAlignment
            )
            .border(aligncolors.first!)

            VStack(alignment: .leading) {
                Text("stack: ")
                    .alignStyled(size: 10)
                Text(stackAlignment.description)
                    .alignStyled(size: 12, .medium)
                Text("srame: ")
                    .alignStyled(size: 10)
                Text(frameAlignment.description)
                    .alignStyled(size: 12, .medium)
            }
            .frame(alignment: .leading)
            .padding(4)
        }
        .frame(alignment: .leading)
    }
}

extension Text {
    func alignStyled(size: CGFloat, _ weight: Font.Weight = .light) -> some View {
        self.font(.system(size: 12, weight: weight, design: .monospaced))
    }
}

struct AlignmentExamples: View {
    struct Pair: Identifiable {
        var id: String { stack.description + frame.description }
        let stack: Alignment
        let frame: Alignment
    }
    let pairs: [Pair] = [
        ///
        (Alignment.top, Alignment.bottom),
        (Alignment.bottom, Alignment.top),
        (Alignment.leading, Alignment.trailing),
        (Alignment.trailing, Alignment.leading),
        ///
        (Alignment.topLeading, Alignment.bottomTrailing),
        (Alignment.topTrailing, Alignment.bottomLeading),
        (Alignment.bottomTrailing, Alignment.topLeading),
        (Alignment.bottomLeading, Alignment.topTrailing),
    ] .map(Pair.init)
    
    let columns = [
        GridItem(.fixed(alignmentExampleSize.width), spacing: 8),
        GridItem(.fixed(alignmentExampleSize.width), spacing: 8),
        GridItem(.fixed(alignmentExampleSize.width), spacing: 8),
        GridItem(.fixed(alignmentExampleSize.width), spacing: 8),
    ]
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(pairs) { pair in
                ZExample(
                    stackAlignment: pair.stack,
                    frameAlignment: pair.frame
                )
                .background(aligncolors.first!.opacity(0.2))
            }
        }
        
//        VStack {
            HStack {
                ForEach(pairs.prefix(4)) { pair in
                    ZExample(
                        stackAlignment: pair.stack,
                        frameAlignment: pair.frame
//                        numberOfSubViews: 6
                    )
                }
            }
//            HStack {
//                ForEach(pairs[4...7]) { pair in
//                    ZExample(
//                        stackAlignment: pair.stack,
//                        frameAlignment: pair.frame,
//                        numberOfSubViews: 6
//                    )
//                }
//            }
            
        }
//    }
}


struct AlignmentPreviews: PreviewProvider {
    static var previews: some View {
        AlignmentExamples()
    }
}
