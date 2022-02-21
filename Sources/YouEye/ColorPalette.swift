import SwiftUI

var basePalette: [Color] = [
    "#5C4B51",
    "#8CBEB2",
    "#F2EBBF",
    "#F3B562",
    "#F06060",
] .map(Color.init)

var harmonyPalette: [Color] = [
    "#4b5c56",
    "#8cbeb2",
    "#bfc6f2",
    "#62a0f3",
    "#60f0f0",
] .map(Color.init)

var palette: [Color] = (basePalette + harmonyPalette)

// MARK: Viewer

struct PaletteViewer: View {
    @State private var base: [Color] = basePalette
    @State private var complementary: [Color] = harmonyPalette
    
    var body: some View {
        VStack {
            ForEach(base.indices, id: \.self) { m in
                HStack {
                    Group {
                        base[m]
                        complementary[m]
                    }
                    .mask(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

struct PalettePreviews: PreviewProvider {
    static var previews: some View {
        PaletteViewer()
            .frame(width: 200, height: 600)
    }
}
