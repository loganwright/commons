import SwiftUI

var testCircle: some View {
    Circle()
        .fill(.red)
        .frame(width: 20, height: 20)
}

//extension View {
//    func test
//}

//var colors: [Color] = [
//    .pink,
//    .yellow,
//    .gray,
//    .purple
//]
//
////extension CGSize {
////    func scal
////}
//
//let outer = CGSize(width: 100, height: 100)

struct TestPreviews: PreviewProvider {
    static var previews: some View {
        HStack {
//            ZStack(alignment: .top) {
//                ForEach(1...3, id: \.self) { idx in
//                    colors[idx]
//                        .frame(width: outer - ((outer / 10) * Double(idx)))
//                }
//            }
//            .frame(width: outer.width, height: outer.height)
            
            /// ** USES INITIALIZED
            ZStack(alignment: .bottom) {
                // added additional view
                Color.clear
                testCircle
                
            }
            .frame(width: 60, height: 60, alignment: .trailing)
            .border(.black)
            
            /// ** USES FRAME (but init declared)
            ZStack { //}(alignment: .bottom) {
                // Rectangle()
                testCircle
                
            }
            // ***
            .frame(width: 60, height: 60, alignment: .leading)
            .border(.black)
            
            /// without initialized alignment
            /// also ignores frame
            ZStack {
                Color.blue.frame(width: 40, height: 40)
                testCircle
                
            }
            // ***
            .frame(width: 60, height: 60, alignment: .trailing)
            .border(.black)
            
            ///
            ZStack {
                Color.clear
                testCircle
                    .alignmentGuide(VerticalAlignment.center) { dimensions in
                        dimensions[.top]
                    }
                
            }
//            .c
            // ***
            .frame(width: 60, height: 60, alignment: .leading)
            .border(.black)
        }
        
    }
}
