import SwiftUI
import Commons

struct ConstrainedAlignmentGuidesExample: View {
    @State private var padding: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                Group {
                    palette[2].overlay(palette[9].frame(width: nil, height: 8))
                    palette[8]
                    palette[4].overlay(
                        palette[1]
                            .mask(Circle())
                            .frame(width: 20, height: 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    )
                    palette[9]
                        .alignmentGuide(.leading) { d in
                            d[HorizontalAlignment.leading] + 32// - 120
                        }
                        .overlay(Rectangle().fill(palette[3]).frame(height: 8))
                    
                }
                .mask(Capsule())
            }
            .padding([.leading, .trailing], padding / 2)
            /// this ensures that our vstack is constrained to its container
            .passGeometry { renderedSize in
                let containerSize = geo.size
                guard renderedSize.size.width > containerSize.width else { return }
                padding = renderedSize.size.width - containerSize.width
            }
            .frame(width: geo.size.width)
        }
        .dashedBorder(palette[3])
        .padding(120)
    }
}

struct AlignmentGuidePreview: PreviewProvider {
    static var previews: some View {
        ConstrainedAlignmentGuidesExample()
    }
}

struct DashedBorder: Shape {
    let width: Double
    func path(in rect: CGRect) -> Path {
        Path(rect).strokedPath(
            StrokeStyle(
                lineWidth: width,
                lineCap: .round,
                lineJoin: .bevel,
                miterLimit: 8,
                dash: [20], //[8, 4, 4],
                dashPhase: 6
            )
        )
    }
}
