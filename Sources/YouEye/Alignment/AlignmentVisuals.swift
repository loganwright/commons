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

var basePalette: [String] = [
    "#5C4B51",
    "#8CBEB2",
    "#F2EBBF",
    "#F3B562",
    "#F06060",
]

var harmonyPalette: [String] = [
    "#4b5c56",
    "#8cbeb2",
    "#bfc6f2",
    "#62a0f3",
    "#60f0f0",
]

var palette: [Color] = (basePalette + harmonyPalette).map(Color.init)
extension Array {
    public subscript(revolving idx: Int) -> Element {
        self[idx % count]
    }
}
//func color(for idx: Int) -> Color {
//    idx %
//}


///
/// stack alignment - aligns subviews internally to each other
/// frame alignment - aligns the content WITHIN self (if content smaller than self)
/// alignment guide - in a given alignment, how the view responds
///
///     MyView()
///     .alignmentGuide(.leading) { d in
///         d[VerticalAlignment.center]
///     }
///
/// read this as 'if my parent's alignment guide is `.leading`,
/// with our current dimensions `d`
/// then `MyView`'s horizontal alignment is returned
///
///

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
let alignmentNumberOfSubviews = 4
var inner: CGSize {
    .init(width: alignmentExampleSize.width * 0.72,
          height: alignmentExampleSize.height * 0.72
    )
}

protocol StackExample {
    init(
        stackAlignment: Alignment,
        frameAlignment: Alignment
    )
}

extension StackExample {
    var stackSize: CGSize { alignmentExampleSize }
    var subviews: Int { alignmentNumberOfSubviews }
    var colorOffset: Int { return 1 }
}

struct ZExample: View, StackExample {
    let stackAlignment: Alignment
    let frameAlignment: Alignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ********
            ZStack(alignment: stackAlignment) {
                ForEach(1...subviews, id: \.self) { idx in
                    palette[revolving: idx + colorOffset]
                        .frame(
                            width: stackSize.scaled(
                                forIdx: idx,
                                total: subviews
                            ).width,
                            height: stackSize.scaled(
                                forIdx: idx,
                                total: subviews
                            ).height
                        )
                }
            }
            .frame(
                width: stackSize.width,
                height: stackSize.height,
                alignment: frameAlignment
            )
            .border(palette.first!)
//            .alignmentGuide(.leading) { d in
//                d[VerticalAlignment.center]
//            }

            VStack(alignment: .leading) {
                Text("stack: ")
                    .alignStyled(size: 10)
                Text(stackAlignment.description)
                    .alignStyled(size: 12, .medium)
                Text("frame: ")
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

struct VExample: View, StackExample {
    let stackAlignment: Alignment
    let frameAlignment: Alignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ********
            VStack(alignment: stackAlignment.horizontal) {
                ForEach(1...subviews, id: \.self) { idx in
                    palette[revolving: idx + colorOffset]
                        .frame(
                            width: inner.scaled(
                                forIdx: idx,
                                total: subviews
                            ).width,
                            height: inner.height / Double(subviews)
                        )
                }
            }
            .frame(
                width: stackSize.width,
                height: stackSize.height,
                alignment: frameAlignment
            )
            .border(palette.first!)

            VStack(alignment: .leading) {
                Text("stack: ")
                    .alignStyled(size: 10)
                Text(stackAlignment.description)
                    .alignStyled(size: 12, .medium)
                Text("frame: ")
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

struct HExample: View {
    let stackAlignment: Alignment
    let frameAlignment: Alignment
    var numberOfSubViews: Int = 4
    var size = alignmentExampleSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ********
            HStack(alignment: stackAlignment.vertical) {
                ForEach(1...numberOfSubViews, id: \.self) { idx in
                    palette[revolving: idx + 1]
                        .frame(
                            width: inner.width / Double(numberOfSubViews),
                            height: inner.scaled(forIdx: idx, total: numberOfSubViews).height
                        )
                }
            }
            .frame(
                width: size.width,
                height: size.height,
                alignment: frameAlignment
            )
            .border(palette.first!)

            VStack(alignment: .leading) {
                Text("stack: ")
                    .alignStyled(size: 10)
                Text(stackAlignment.description)
                    .alignStyled(size: 12, .medium)
                Text("frame: ")
                    .alignStyled(size: 10)
                Text(frameAlignment.description)
                    .alignStyled(size: 12, .medium)
//                    .frame(width: <#T##CGFloat?#>, height: <#T##CGFloat?#>, alignment: <#T##Alignment#>)
            }
            .frame(alignment: .leading)
            .padding(4)
        }
        .frame(alignment: .leading)
    }
}

extension Text {
    func alignStyled(size: CGFloat, _ weight: Font.Weight = .light) -> some View {
        self.font(.system(size: size, weight: weight, design: .monospaced))
    }
}

extension Alignment {
    static var allCases: [Alignment] {
        return [
            .top,
            .trailing,
            .bottomLeading,
            .leading,
            //
            .topLeading,
            .topTrailing,
            .bottomTrailing,
            .bottomLeading
        ]
    }
}

struct Pair<T>: Identifiable {
    var id: String { "\(lhs)" + "\(rhs)" }
    let lhs: T
    let rhs: T
}
extension Array {
    var allPairs: [Pair<Element>] {
        var pairs = [Pair<Element>]()
        self.forEach { item in
            pairs += self.map { .init(lhs: item, rhs: $0) }
        }
        return pairs
    }
}

extension Pair where T == Alignment {
    var stack: Alignment { lhs }
    var frame: Alignment { rhs }
    
}
struct AlignmentExamples: View {
    let pairs: [Pair<Alignment>] = Alignment.allCases.allPairs
    let classypairs: [Pair<Alignment>] = [
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
        ScrollView {
            Text("Z Stack")
                .alignStyled(size: 24, .thin)
            
            LazyVGrid(columns: columns) {
                ForEach(pairs) { pair in
                    ZExample(
                        stackAlignment: pair.stack,
                        frameAlignment: pair.frame
                    )
                    .background(palette.first!.opacity(0.2))
                }
            }
            
            Text("V Stack")
                .alignStyled(size: 24, .thin)
            
            LazyVGrid(columns: columns) {
                ForEach(pairs) { pair in
                    VExample(
                        stackAlignment: pair.stack,
                        frameAlignment: pair.frame
                    )
                    .background(palette.first!.opacity(0.2))
                }
            }
            
            Text("H Stack")
                .alignStyled(size: 24, .thin)
            
            LazyVGrid(columns: columns) {
                ForEach(pairs) { pair in
                    HExample(
                        stackAlignment: pair.stack,
                        frameAlignment: pair.frame
                    )
                    .background(palette.first!.opacity(0.2))
                }
            }
        }
        
//        VStack {
//            HStack {
//                ForEach(pairs.prefix(4)) { pair in
//                    ZExample(
//                        stackAlignment: pair.stack,
//                        frameAlignment: pair.frame
////                        numberOfSubViews: 6
//                    )
//                }
//            }
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
