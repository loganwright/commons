//import SwiftUI
//
//extension Binding {
//    func logging(key: String) -> Self {
//        Binding {
//            Log.debug("@Binding.get(\(key)) \(self.wrappedValue)")
//            return self.wrappedValue
//        } set: { new in
//            Log.debug("@Binding.set(\(key))")
//            Log.debug("current: \(self.wrappedValue)")
//            Log.debug("new: \(new)")
//            self.wrappedValue = new
//        }
//
//    }
//}
//
//struct Ma: View {
//    @Binding var text: String
//    
//    var body: some View {
//        Trush(text: $text.logging(key: "\(Self.self)"))
//    }
//}
//
//struct Trush: View {
//    @Binding var text: String
//    
//    var body: some View {
//        Ka(text: $text.logging(key: "\(Self.self)"))
//    }
//}
//
//
//struct Ka: View {
//    @Binding var text: String
//    
//    var body: some View {
//        VStack {
//            Text("Actual Editing")
//                .commonStyle(size: 18, .thin)
//            
//            TextField("...", text: $text.logging(key: "\(Self.self)"))
//        }
//    }
//}
//
//import Commons
//
//public final class PreviewLogger: LogOutput, ObservableObject {
//    static let shared = PreviewLogger()
//    
//    public var levels: [Log] = .allCases
//    // TODO: Organize by level
//    @Published private(set) var logs: [Entry] = []
//    private init() {}
//    
//    public func log(_ entry: Entry) {
//        guard levels.contains(entry.level) else { return }
//        logs.append(entry)
//    }
//    
//    public var body: some View {
//        ScrollView {
//            Text(logs.map(\.msg).joined(separator: "\n"))
//                .multilineTextAlignment(.leading)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .dashedBorder()
//    }
//}
//
//struct PreviewConsole: View {
//    let logger: PreviewLogger
//    var body: some View {
//        ScrollView {
//            Text(logger.logs.map(\.msg).joined(separator: "\n"))
//                .multilineTextAlignment(.leading)
//        }
//        .frame(minHeight: 44)
//        .dashedBorder()
//    }
//}
//
//
//extension Binding where Value == Entry {
//    
//}
//
//
//
//struct BRoot: View {
//    @State private var text = "<initial>"
//    
//    var body: some View {
//        Ma(text: $text.logging(key: "\(Self.self)"))
//    }
//}
//
//struct ShowConsole: ViewModifier {
//    let logger: PreviewLogger
//    
//    init(_ logger: PreviewLogger) {
//        self.logger = logger
//        guard !Log.outputs.contains(where: { $0 is PreviewLogger }) else { return }
//        Log.outputs.append(PreviewLogger.shared)
//    }
//    
//    func body(content: Content) -> some View {
//        VStack {
//            content
//            PreviewConsole(logger: logger)
//                .frame(height: 240)
//                .border(Color.primary)
//            Color.green.frame(height: 8)
//        }
//    }
//}
//
//extension View {
//    func showConsole(logger: PreviewLogger = .shared) -> some View {
//        modifier(ShowConsole(logger))
//    }
//}
//
//struct BLogg_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack(alignment: .topLeading) {
//            BRoot()
//                .showConsole()
//                .onAppear {
//                    Log.critical("is it working?")
//                }
//                .previewDevice("iPhone 12")
//            
//            Button {
//                Log.info("aieeeee")
//            } label: {
//                Text("•")
//            }
//            .buttonStyle(TestButtonStyle())
//            .frame(width: 60, height: 60)
//            
//        }
//    }
//}
