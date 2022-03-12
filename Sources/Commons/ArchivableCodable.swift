import Foundation

/// used to bridge nsobjects that support nscoding
/// but not codable to gain automatic
/// conformance through property wrappers
///
///     @ArchivableCodable
///     var myThing: HTTPURLResponse
///
/// idk what will happen if you serialize this to a server
/// it's more intended for internal storage/recovery
@propertyWrapper
@dynamicMemberLookup
public struct ArchivableCodable<T>: Codable where T: NSObject, T: NSCoding {
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let data = try Data(from: decoder)
        guard let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data) else {
            throw "unable to unarchive data: \(data.string ?? data.count.description)"
        }
        self.wrappedValue = unarchived
    }
    
    public func encode(to encoder: Encoder) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: wrappedValue, requiringSecureCoding: false)
        try data.encode(to: encoder)
    }
    
    public subscript<U>(dynamicMember kp: KeyPath<T, U>) -> U {
        wrappedValue[keyPath: kp]
    }
    
    public subscript<U>(dynamicMember kp: WritableKeyPath<T, U>) -> U {
        get {
            wrappedValue[keyPath: kp]
        }
        set {
            wrappedValue[keyPath: kp] = newValue
        }
    }
}
