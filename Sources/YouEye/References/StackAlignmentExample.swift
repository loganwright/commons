import SwiftUI

extension CGSize {
    fileprivate func scaled(forIdx idx: Int, total: Int) -> CGSize {
        let wSegments = width / (Double(total) * 1.2)
        let w = width - (wSegments * Double(idx))
        
        let hSegments = height / (Double(total) * 1.2)
        let h = width - (hSegments * Double(idx))
        return CGSize(width: w, height: h)
    }
    fileprivate func distributed(total: Int) -> CGSize {
        CGSize(
            width: width / Double(total),
            height: height / Double(total)
        )
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
        default: return "unknown alignment: \(self)"
        }
    }
}

// MARK: SizeConstants

/// the size of the stack being displayed
fileprivate let stackSize = CGSize(width: 120, height: 120)
/// the size of the content to show in the stack
/// the content MUST be smaller to see the effects
/// of frame alignment
fileprivate let stackContentSize = CGSize(
    width: stackSize.width * 0.72,
    height: stackSize.height * 0.72
)
/// the number of subviews to render inside of the stack's
/// content
fileprivate let stackItemCount = 4
/// equally scaled down
fileprivate func scaledItemSize(idx: Int) -> CGSize {
    stackContentSize.scaled(forIdx: idx, total: stackItemCount)
}
/// distributed
fileprivate let distributedItemSize: CGSize = stackContentSize.distributed(total: stackItemCount)


//fileprivate lett

// MARK: Stack Views

enum ItemSizingPreference {
    case scaled,
         distributed
}

protocol StackView: View {
    associatedtype Content: View
    static func itemSize(idx: Int) -> CGSize
    init(alignment: Alignment, @ViewBuilder content: () -> Content)
}
extension ZStack: StackView {
    static func itemSize(idx: Int) -> CGSize {
        stackSize.scaled(forIdx: idx, total: stackItemCount)
    }
}
extension VStack: StackView {
    static func itemSize(idx: Int) -> CGSize {
        CGSize(
            width: scaledItemSize(idx: idx).width,
            height: distributedItemSize.height
        )
    }
    init(alignment: Alignment, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment.horizontal, content: content)
    }
}
extension HStack: StackView {
    static func itemSize(idx: Int) -> CGSize {
        CGSize(
            width: distributedItemSize.width,
            height: scaledItemSize(idx: idx).height
        )
    }
    init(alignment: Alignment, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment.vertical, content: content)
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
    var allPossiblePairs: [Pair<Element>] {
        var pairs = [Pair<Element>]()
        self.forEach { item in
            pairs += self.map { .init(lhs: item, rhs: $0) }
        }
        return pairs
    }
}

extension Array where Element == Pair<Alignment> {
    static var overview: [Pair<Alignment>] {
        return [
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
        
    }
}

extension Pair where T == Alignment {
    var stack: Alignment { lhs }
    var frame: Alignment { rhs }
}

struct AlignmentExamples: View {
    /// currently visible pairs
    /// the accessor of currently vis keyPath
    var pairs: [Pair<Alignment>] { self[keyPath: viewing] }
    
    @State private var viewing: KeyPath<Self, [Pair<Alignment>]> = \.overview
    
    /// displays every possible combination
    let allPossibilitoes: [Pair<Alignment>] = Alignment.allCases.allPossiblePairs
    /// displays opposites, best for overview
    let overview: [Pair<Alignment>] = .overview
    
    let columns: [GridItem] = {
        let count: Int
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            count = 4
        } else {
            count = 3
        }
#else
        // mac
        count = 4
#endif
        return [GridItem](
            repeating: GridItem(.fixed(stackSize.width), spacing: 8),
            count: count
        )
    }()
    
    var body: some View {
        ScrollView {
            ExampleSet<ZStack>(columns: columns, pairs: pairs)
            ExampleSet<VStack>(columns: columns, pairs: pairs)
            ExampleSet<HStack>(columns: columns, pairs: pairs)
            
            Color.clear.frame(height: 44)
        }
    }
}

struct ExampleSet<Stack: StackView>: View where Stack.Content == ColorViews {
    var title: String = "\(Stack.self)".first!.description + " Stack"
    let columns: [GridItem]
    let pairs: [Pair<Alignment>]
    
    var body: some View {
        Text(title)
            .alignStyled(size: 24, .thin)
        
        LazyVGrid(columns: columns) {
            ForEach(pairs) { pair in
                ExampleCell<Stack>(stackAlignment: pair.stack,
                                   frameAlignment: pair.frame)
                    .background(palette.first!.opacity(0.2))
            }
        }
        
    }
}

struct ColorViews: View {
    var colorOffset: Int { return 1 }
    
    let itemSizing: (Int) -> CGSize
    
    var body: some View {
        ForEach(1...stackItemCount, id: \.self) { idx in
            palette[revolving: idx + colorOffset]
                .frame(width: itemSizing(idx).width,
                       height: itemSizing(idx).height)
        }
    }
}


struct ExampleCell<Stack: StackView>: View where Stack.Content == ColorViews {
    let stackAlignment: Alignment
    let frameAlignment: Alignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ********
            Stack(alignment: stackAlignment) {
                ColorViews(itemSizing: Stack.itemSize(idx:))
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

struct AlignmentPreviews: PreviewProvider {
    static var previews: some View {
        AlignmentExamples()
    }
}
