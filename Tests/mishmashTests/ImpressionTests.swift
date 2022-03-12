import XCTest
import Commons

class ImpressionTests: XCTestCase {
    func testRead() {
        let user = User()
        let userImpression = Impression(label: .key("Top Level"), value: user)
        let arrayImpression = Impression(label: .key("Top Level"), value: ["i", "am", "a", "list"])
        XCTAssert(userImpression.children.count == 5)
        XCTAssertEqual(arrayImpression.children.map(\.label), [0, 1, 2, 3].map(Impression.Label.idx))
    }
}

struct User {
    var name: String = "Some Youze"
    var nickname: String? = nil

    var age: Int = 44
    var email: Email = try! Email("s.youze@nomail.com")
    
    var preferences: Preferences = Preferences()
}

struct Preferences {
    var enableNotifications: Bool = false
    var showTips: Bool = true
}

final class Impression {
    let type: String
    enum Label: Equatable {
        case key(String)
        case idx(Int)
    }
    let label: Label
    let value: Any
    lazy var children: [Impression] = loadChildren()
    
    init(label: Label, value: Any) {
        self.label = label
        self.type = "\(Swift.type(of: value))"
        self.value = value
    }
    
    private func loadChildren() -> [Impression] {
        var children = [Impression]()
        
        Mirror(reflecting: value).children.enumerated().forEach { idx, property in
            let label: Label
            if let name = property.label {
                label = .key(name)
            } else {
                label = .idx(idx)
            }
            
            children.append(.init(label: label, value: property.value))
        }
        
        return children
    }
}

extension Impression.Label: CustomStringConvertible {
    var description: String {
        switch self {
        case .key(let k):
            return k
        case .idx(let i):
            return i.description
        }
    }
}


private let indentSpaces = 2
extension Impression: CustomStringConvertible {
    enum Level {
       case detail, meta, values
    }
    
    func display(level: Level) -> String {
        switch level {
        case .detail:
            fatalError()
        case .meta:
            fatalError()
        case .values:
            fatalError()
        }
    }
    
    var header: String {
        "\(label): \(type)"
    }
    
    func displayDetail(includeTypes: Bool, indent level: Int = 1) -> String {
        var desc = "\(label): "
        if includeTypes {
            desc += "\(type)"
        }
        if children.isEmpty {
            desc += "(\(value))"
        }
        

        let indent = String(repeating: " ", count: level * indentSpaces)
        children.forEach { child in
            desc += "\n\(indent)\(child.displayDetail(includeTypes: includeTypes, indent: level + 1))"
        }
        return desc
    }
    
    var description: String {
        displayDetail(includeTypes: true)
    }
}

/**
 Top Level: (User)
   name: Some Youze (String)
   nickname: nil (Optional<String>)
   age: 44 (Int)
   email: (Email)
     wrappedValue: s.youze@nomail.com
   preferences: (Preferences)
     enableNotifications: false (Bool)
     showTips: true (Bool)
 
 User(Top Level):
   String(name): Some Youze
   String('nickname'): nil
   Int('age'): 44
   email:
     wrappedValue: s.youze@nomail.com
   preferences:
     enableNotifications: false
     showTips: true
 
 Top Level: User
   name: Some Youze
   nickname: nil
   age: 44
   email: Email
     wrappedValue: s.youze@nomail.com
   preferences: Preferences
     enableNotifications: false
     showTips: true
 
 Top Level: User
   name: String(Some Youze)
   nickname: Optional<String> - nil
   age: Int
   email: Email
     wrappedValue: s.youze@nomail.com
   preferences: Preferences
     enableNotifications: false
     showTips: true
 */
