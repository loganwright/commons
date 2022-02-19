#if canImport(SwiftUI)
import SwiftUI
import Foundation

/// a simple storage that supports codable objects
/// conforming codable objects to raw representable
/// was creating issues
///
/// right now only supports optionals :/
@available(iOS 14, *)
@propertyWrapper
public struct CodableStorage<C: Codable> {
    public var wrappedValue: C {
        get {
            do {
                return try backing.wrappedValue.decode()
            } catch {
                Log.error("codable storage failed decode: \(error)")
                return initial
            }
        }
        set {
            do {
                backing.wrappedValue = try newValue.encoded()
//                backing.update()
            } catch {
                Log.error("codable storage failed encode: \(error)")
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
            let initial = try wrappedValue.encoded()
            storage = AppStorage<Data>(wrappedValue: initial, key, store: store)
        } catch {
            storage = AppStorage<Data>(wrappedValue: .init(), key, store: store)
        }
        self.backing = storage
    }
}


#endif
