//import SwiftUI
//import Commons
//
//
//struct User {
//    var name: String = "Some Youze"
//    var nickname: String? = nil
//
//    var age: Int = 44
//    var email: Email = try! Email("s.youze@nomail.com")
//    
//    var premium: Bool = false
//    
//    var preferences: Preferences = Preferences()
//}
//
//struct Preferences {
//    var enableNotifications: Bool = false
//    var showTips: Bool = true
//}
//
//final class Impression {
//    let type: String
//    enum Label {
//        case key(String)
//        case idx(Int)
//    }
//    let label: Label
//    let value: Any
//    lazy var children: [Impression] = loadChildren()
//    
//    init(label: Label = .key(""), value: Any) {
//        self.label = label
//        self.type = "\(Swift.type(of: value))"
//        self.value = value
//    }
//    
//    private func loadChildren() -> [Impression] {
//        var children = [Impression]()
//        Mirror(reflecting: value).children.enumerated().forEach { idx, property in
//            let label: Label
//            if let name = property.label {
//                label = .key(name)
//            } else {
//                label = .idx(idx)
//            }
//            children.append(.init(label: label, value: property.value))
//        }
//        
//        return children
//    }
//}
//
//struct MetaForm: View {
//    let impression: Impression
//    
//    var body: some View {
//        Text("eyo")
//    }
//}
//
////extension View {
////    func field<T: EditableType>(_ set: Binding<T>) -> some View {
////        self
////        set.
////    }
////}\
//
/////
/////
///// foo
/////
/////     FormModel<UserProfile>(editing: )
/////         .name()
/////         .field($name)
/////         .field($age)
/////         .field($position) {
/////             CustomEditing(binding)
/////         }
/////
/////
//
///**
// Button
// 
//    as
// */
//
//protocol FormValue {
//    associatedtype V: View
//    func formView(title: String, with binding: Binding<Self>) -> V
//}
//
//extension Bool: FormValue {
//    func formView(title: String, with binding: Binding<Self>) -> some View {
//        Toggle(title, isOn: binding)
//    }
//}
//
//extension String: FormValue {
//    func formView(title: String, with binding: Binding<Self>) -> some View {
//        TextField(title, text: binding)
//    }
//}
//
//extension View {
//    var erased: AnyView {
//        AnyView(self)
//    }
//}
//
//struct Forms {
//    final class Field<Item>: Identifiable {
//        let id: String
//        let title: String
//        var value: Any
//        
//        ///
//        private(set) var content: AnyView! = nil
//        private(set) var apply: ((inout Item) -> Void)! = nil
//        
//        init<Value: FormValue>(title: String, value: Value, kp: WritableKeyPath<Item, Value>) {
//            self.id = UUID().uuidString
//            self.title = title
//            self.value = value
//            self.content = value.formView(
//                title: title,
//                with: Binding(
//                    get: { [weak self] in
//                        guard let v = self?.value else { return value }
//                        return v as! Value
//                    }, set: { [weak self] in
//                        self?.value = $0
//                    }
//                )
//            ).erased
//            self.apply = { [unowned self] item in
//                item[keyPath: kp] = self.value as! Value
//            }
//        }
//    }
//    
//    struct FieldBuilder<Item, Value: FormValue> {
//        let model: Model<Item>
//        let kp: WritableKeyPath<Item, Value>
//        
//        func callAsFunction(title: String) -> Model<Item> {
//            let value = model.initial[keyPath: kp]
//            let field = Field(title: title, value: value, kp: kp)
//            model.fields.append(field)
//            return model
//        }
//    }
//    
//    @dynamicMemberLookup
//    final class Model<Item> {
//        let title: String
//        let initial: Item
//        
//        fileprivate(set) var fields: [Field<Item>] = []
//        
//        init(_ title: String, _ value: Item) {
//            self.title = title
//            self.initial = value
//        }
//        
//        subscript<T>(dynamicMember kp: WritableKeyPath<Item, T>) -> FieldBuilder<Item, T> {
//            FieldBuilder(model: self, kp: kp)
//        }
//    }
//}
//
//var currentUser = User()
//func makeForm() -> Forms.Model<User> {
//    Forms.Model("Profile", currentUser)
//        .name(title: "Your Name")
//        .premium(title: "Enable Premium")
////        .age(title: "age")
////        .nickname(title: "nickname")
////        .preferences(title: "prefs")
////        .nickname
//}
//
//struct Editor<Item>: View {
//    let model: Forms.Model<Item>
//    
//    var body: some View {
//        VStack {
//            Text(model.title)
//                .commonStyle(size: 32, .bold)
//            
//            ScrollView {
//                LazyVStack {
//                    ForEach(model.fields) { field in
//                        field.content
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct Foo: View {
//    var body: some View {
////        MetaForm<String>()
//        Editor(model: makeForm())
//    }
//}
//@available(macOS 12, *)
//struct TPrevs: PreviewProvider {
//    static var previews: some View {
//        Foo()
//    }
//}
//
//
//extension Impression.Label: CustomStringConvertible {
//    var description: String {
//        switch self {
//        case .key(let k):
//            return k
//        case .idx(let i):
//            return i.description
//        }
//    }
//}
//
//
//private let indentSpaces = 2
//extension Impression: CustomStringConvertible {
//    enum Level {
//       case detail, meta, values
//    }
//    
//    func display(level: Level) -> String {
//        switch level {
//        case .detail:
//            fatalError()
//        case .meta:
//            fatalError()
//        case .values:
//            fatalError()
//        }
//    }
//    
//    var header: String {
//        "\(label): \(type)"
//    }
//    
//    func displayDetail(includeTypes: Bool, indent level: Int = 1) -> String {
//        var desc = "\(label): "
//        if includeTypes {
//            desc += "\(type)"
//        }
//        if children.isEmpty {
//            desc += "(\(value))"
//        }
//        
//
//        let indent = String(repeating: " ", count: level * indentSpaces)
//        children.forEach { child in
//            desc += "\n\(indent)\(child.displayDetail(includeTypes: includeTypes, indent: level + 1))"
//        }
//        return desc
//    }
//    
//    var description: String {
//        displayDetail(includeTypes: true)
//    }
//}
