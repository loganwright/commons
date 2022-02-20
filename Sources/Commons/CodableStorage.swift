import SwiftUI
import Foundation

/// a simple storage that supports codable objects
/// conforming codable objects to raw representable
/// was creating issues
///
/// right now only supports optionals :/
@propertyWrapper
public struct CodableStorage<C: Codable> {
    public var wrappedValue: C {
        get {
            catching {
                try backing.wrappedValue.decode()
            } ?? initial
        }
        set {
            catching {
                backing.wrappedValue = try newValue.encode()
            }
        }
    }
    

    public let key: String
    public let store: UserDefaults?

    private let initial: C
    private var backing: AppStorage<Data>
    
    public init(wrappedValue: C, _ key: String, store: UserDefaults? = nil) {
        self.key = key
        self.store = store
        self.initial = wrappedValue
        
        let storage: AppStorage<Data>
        do {
            let initial = try wrappedValue.encode()
            storage = AppStorage<Data>(wrappedValue: initial, key, store: store)
        } catch {
            storage = AppStorage<Data>(wrappedValue: .init(), key, store: store)
        }
        self.backing = storage
    }
}
