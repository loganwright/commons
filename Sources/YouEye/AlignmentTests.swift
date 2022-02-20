import SwiftUI

var colors: [Color] = [
    .pink,
    .yellow,
    .gray,
    .purple
]

//extension CGSize {
//    func scal
//}

let outer = CGSize(width: 100, height: 100)
extension CGSize {
    func scaled(forIdx idx: Int, total: Int) -> CGSize {
        let wSegments = width / (Double(total) * 2)
        let w = width - (wSegments * Double(idx))
        
        let hSegments = height / (Double(total) * 2)
        let h = width - (hSegments * Double(idx))
        return CGSize(width: w, height: h)
    }
    
}

struct AlignmentPreviews: PreviewProvider {
    static var numberOfSubs = 3
    static var previews: some View {
        ZStack(alignment: .top) {
            ForEach(1...numberOfSubs, id: \.self) { idx in
                colors[idx]
                    .frame(
                        width: outer.scaled(forIdx: idx, total: numberOfSubs).width,
                        height: outer.scaled(forIdx: idx, total: numberOfSubs).height
                    )
            }
        }
        .frame(width: outer.width, height: outer.height)
    }
}
