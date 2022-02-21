//import SwiftUI
//
//struct Next: View {
//    var body: some View {
//        Group {
//            NavigationLink {
//                Next()
//            } label: {
//                Text("HIIII")
//            }
//        }
//    }
//}
//
//@available(iOS 15, *)
//struct StylePrevs: PreviewProvider {
//    static let strt = Date()
//    static var previews: some View {
//        NavigationView {
//            VStack {
//                NavigationLink {
//                    Next()
//                } label: {
//                    Text("I'm a text field")
//                }
//                
//                TimelineView(.periodic(from: strt, by: 0.1)) { ctxt in
//                    Text("\(ctxt.date.timeIntervalSince(strt))")
//                }
//               
//                ForegroundStyleExample()
//                
//            }
//        }
//        .font(.system(size: 24, weight: .thin, design: .monospaced))
////        .labelStyle(MyStye())
////        .textFieldStyle(TextField)
//
//    }
//}
//
//struct Styles {
//    @ScaledMetric(relativeTo: .body) var foo: Double = 14
//}
//
//@available(iOS 15, *)
//struct ForegroundStyleExample: View {
//    var body: some View {
//        VStack {
//            Text("DevTechie")
//            Image(systemName: "globe")
//            Capsule()
//                .foregroundStyle(.secondary)
//                .frame(height: 50)
//                .overlay(
//                    Text("SwiftUI 3")
////                        .foregroundStyle(.black)
//                        .foregroundColor(.pink)
//                )
//            
////            ZStack {
////                Rectangle().fill(.green.opacity(0.3))
////                    .overlay(Text("mohr"))
////            }
//            
//            VStack(alignment: .leading) {
//                Text("huh")
////                    .anchor
//                Label("Primary", systemImage: "1.square.fill")
//                Label("Secondary", systemImage: "2.square.fill")
//                    .foregroundStyle(.secondary)
//            }
//            .foregroundStyle(.blue)
//        }
//        .font(.system(size: 42))
//        .foregroundStyle(
//            .linearGradient(
//                colors: [.pink, .orange],
//                startPoint: .top,
//                endPoint: .bottom
//            ),
//            .conicGradient(
//                colors: palette,
//                center: .center
//            )
//        )
////        .foregroundStyle(
////            LinearGradient(
////                colors: [.pink, .orange],
////                startPoint: .top,
////                endPoint: .bottom)
////        )
//    }
//}
