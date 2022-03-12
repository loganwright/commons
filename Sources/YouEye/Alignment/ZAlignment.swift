import SwiftUI

extension Alignment {
    private enum MyH : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.h.center]
        }
    }
    private enum MyV : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.v.center]
        }
    }
    
    var h: HorizontalAlignment { horizontal }
    var v: VerticalAlignment { vertical }
    
    static let mine = Alignment(
        horizontal: .init(MyH.self),
        vertical: .init(MyV.self)
    )
}

extension HorizontalAlignment {
    static var h: HorizontalAlignment.Type { Self.self }
    static var mine: Alignment { .mine }
}
extension VerticalAlignment {
    static var v: VerticalAlignment.Type { Self.self }
    static var mine: Alignment { .mine }
}

struct ZAlign: View {
    
    var body: some View {
        ZStack(alignment: .mine) {
            VStack {
                threeH(align: false)
                threeH(align: true)
                threeH(align: false)
            }
            
            Circle()
                .fill(palette[2])
                .frame(width: 15, height: 15)
        }
        .onTapGesture { location in
            
        }
    }
    
    func threeH(align: Bool) -> some View {
        HStack {
            ForEach(0...2, id: \.self) { idx in
                if align, idx == 0 {
                    Circle()
                        .fill(palette[4])
                        .frame(width: 30, height: 30)
                        .alignmentGuide(.mine.h) { $0[.h.center] }
                        .alignmentGuide(.mine.v) { $0[.v.center] }
                } else {
                    Circle()
                        .fill(palette[4])
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
}

@available(iOS 15, *)
@available(macOS 12, *)
struct Blank: View {
    var body: some View {
        Rectangle()
            .fill(.background)
            .border(.primary, width: 2)
    }
}

@available(iOS 15, *)
@available(macOS 12, *)
struct CenteredHeader: View {
    var body: some View {
        VStack {
            Blank()
                .frame(width: 200, height: 100)
                .alignmentGuide(.mine.v, computeValue: \.centerV)
            Text("•••")
            Text("•••")
            Text("•••")
            Text("•••")
        }
        .padding(8)
        .dashedBorder(.primary, 2)
    }
}

extension ViewDimensions {
    var centerV: CGFloat { self[.v.center] }
    var centerH: CGFloat { self[.h.center] }
}

@available(iOS 15, *)
@available(macOS 12, *)
var optOne: some View {
    ZStack {
        CenteredHeader()
    }
    .frame(width: 240, height: 400, alignment: .mine)
    .border(.primary)
    .padding(4)
    .border(.primary)
}


@available(iOS 15, *)
@available(macOS 12, *)
struct ZAlignPreview: PreviewProvider {
    static var previews: some View {
        optOne.padding(12).containerShape(Rectangle())
    }
}
