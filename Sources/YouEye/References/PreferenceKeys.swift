import SwiftUI

struct ViewMeta: Equatable {
    var tag: String
    var size: CGSize?
}

struct NoteTrail: PreferenceKey {
    static var defaultValue: [String] = []

    static func reduce(value: inout [String], nextValue: () -> [String]) {
        value += nextValue()
    }
}

extension View {
    func addNote(_ info: String) -> some View {
        self.preference(key: NoteTrail.self, value: [info])
    }
}

struct BaseView: View {
    @State private var title = "<>"
    var body: some View {
        VStack {
            ZStack {
                palette[3]
                Text(title)
                    .multilineTextAlignment(.leading)
            }
            NavigationView {
                ScrollView {
                    ForEach(1...100, id: \.self) { initial in
                        NavigationLink {
                            Child(history: [initial])
                        } label: {
                            Text("gooo -> \(initial)")
                        }
                        .padding(12)
                    }
                }
            }
        }
        .onPreferenceChange(NoteTrail.self) { trail in
            self.title = trail.joined(separator: "\n")
        }
    }
}

struct Child: View {
    let history: [Int]
    
    var body: some View {
        VStack {
            NavigationLink {
                Child(history: history + [history.last! + 1])
            } label: {
                Text("NEXT")
            }
            
            ForEach(history, id: \.self) { id in
                Text("Child: \(id)")
            }
        }
        .addNote("visiting: \(history.first!).\(history.last!)")
        
    }
}

struct PreferenceKeysPreviews: PreviewProvider {
    static var previews: some View {
        BaseView()
    }
}
