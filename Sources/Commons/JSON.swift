import Foundation

extension JSON {
    public static let emptyObj: JSON = .obj([:])
}

/// a very basic JSON object that can help
/// with the fuzzier side of data when working
/// with swift
///
/// it's really useful as an object for mocking
/// and iterating, or for the background as
/// abstract structured data
///
/// properties are NOT typesafe, be careful..
///     json.some.key.can.go.here
@dynamicMemberLookup
public enum JSON: Codable, Equatable {
    case int(Int)
    case double(Double)
    case str(String)
    case bool(Bool)
    case null
    case array([JSON])
    case obj([String: JSON])

    public init(from decoder: Decoder) throws {
        if let val = try? Int.init(from: decoder) {
            self = .int(val)
        } else if let val = try? Double(from: decoder) {
            self = .double(val)
        } else if let val = try? String(from: decoder) {
            self = .str(val)
        } else if let val = try? Bool(from: decoder) {
            self = .bool(val)
        } else if let isNil = try? decoder.singleValueContainer().decodeNil(), isNil {
            self = .null
        } else if let val = try? [String: JSON](from: decoder) {
            self = .obj(val)
        } else if let val = try? [JSON](from: decoder) {
            self = .array(val)
        } else {
            throw "unexpected type, can't decode"
        }
    }

    public func encode(to encoder: Swift.Encoder) throws {
        switch self {
        case .int(let val):
            try val.encode(to: encoder)
        case .double(let val):
            try val.encode(to: encoder)
        case .str(let val):
            try val.encode(to: encoder)
        case .bool(let val):
            try val.encode(to: encoder)
        case .obj(let val):
            try val.encode(to: encoder)
        case .array(let val):
            try val.encode(to: encoder)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

// MARK: Dynamic Path

public struct Link {
    public let segment: String
    public init(_ segment: String) {
        self.segment = segment
    }
}

@dynamicMemberLookup
public struct LinkedPath {
    public var json: JSON
    public let root: Link

    @Box
    public var children: [Link] = []

    fileprivate init(_ json: JSON, segment: String) {
        self.json = json
        self.root = Link(segment)
    }
    
    public subscript(dynamicMember key: String) -> LinkedPath {
        get {
            children.append(Link(key))
            return self
        }
        set {
            self = newValue
        }
    }
    
    public subscript(dynamicMember key: String) -> JSON? {
        get {
            json[path + [key]]
        }
        set {
            json[path + [key]] = newValue
        }
    }
    
    public subscript<C: Codable>(dynamicMember key: String) -> C? {
        get {
            catching {
                try self[dynamicMember: key]?.convert()
            }
        }
        set {
            self[dynamicMember: key] = catching {
                try newValue?.convert()
            }
        }
    }
    
    /// recursive, don't go crazy on nested
    /// properties lol
    private var path: [String] {
        [root.segment] + children.map(\.segment)
    }
}

extension JSON {
    public subscript(dynamicMember key: String) -> LinkedPath {
        get {
            LinkedPath(self, segment: key)
        }
        set {
            self = newValue.json
        }
    }
    
    public subscript(dynamicMember key: String) -> JSON? {
        get {
            return self[key]
        }
        set {
            self[key] = newValue
        }
    }

    public subscript<C: Codable>(dynamicMember key: String) -> C? {
        get {
            catching {
                try self[key]?.convert()
            }
        }
        set {
            self[key] = catching {
                try newValue?.convert()
            }
        }
    }
}

extension Encodable  {
    /// this is intended to override the
    /// other convert methods
    /// to facilitate
    public func convert() throws -> JSON {
        switch self {
        case let s as String:
            return .str(s)
        case let d as Double:
            return .double(d)
        case let i as Int:
            return .int(i)
        case let b as Bool:
            return .bool(b)
        case let j as JSON:
            return j
        case let d as Data:
            do {
                return try d.decode()
            } catch {
                Log.warn("unable to decode JSON from data, attempting decode as String")
                if let str = d.string {
                    return .str(str)
                } else {
                    throw "unable to convert Data to JSON, setting empty string"
                }
            }
        default:
            return try self.convert()
        }
    }
}

// MARK: Typing

extension JSON {
    public var int: Int? {
        switch self {
        case .int(let i): return i
        case .double(let d): return Int(d)
        case .str(let s): return Int(s)
        case .bool(let b): return b ? 1 : 0
        default: return nil
        }
    }

    public var float: Float? {
        double.flatMap(Float.init)
    }

    public var double: Double? {
        switch self {
        case .double(let d): return d
        case .int(let i): return Double(i)
        case .str(let s): return Double(s)
        case .bool(let b): return b ? 1 : 0
        default: return nil
        }
    }
    public var string: String? {
        switch self {
        case .int(let val): return val.description
        case .double(let val): return val.description
        case .str(let val): return val
        case .bool(let val): return val.description
        case .array(let arr) where arr.count == 1: return arr[0].string
        default: return nil
        }
    }
    public var bool: Bool? {
        switch self {
        case .bool(let b):
            return b
        case .int(let i) where i == 0 || i == 1:
            return i == 1
        case .double(let d) where d == 0 || d == 1:
            return d == 1
        case .str(let s):
            return Bool(s.lowercased())
        case .array(let arr) where arr.count == 1:
            /// in some places (consent test) we get `["False"]` for example
            return arr[0].bool
        default:
            return nil
        }
    }

    public var null: Bool {
        guard case .null = self else { return false }
        return true
    }

    public var obj: [String: JSON]? {
        switch self {
        case .obj(let v):
            return v
        case .str(let str):
            return catching {
                try str.data.decode()
            }
        default:
            return nil
        }
    }
    
    public var array: [JSON]? {
        switch self {
        case .array(let v):
            return v
        case .str(let str):
            return catching {
                try str.data.decode()
            }
        default:
            return nil
        }
    }
}

extension JSON {
    /// if the JSON is an object, or an array
    /// it will encode appropriate JSON
    ///
    /// all other types will be the underlying type,
    /// encoded
    ///
    /// in this way, if a key is for example, a JSON.str
    /// but a valid json object, it will be extracted
    public var rawData: Data? {
        switch self {
        case .str(let val):
            return Data(val.utf8)
        case .array(let arr):
            return catching { try arr.encode() }
        case .obj(let obj):
            return catching { try obj.encode() }
        case .int(let val):
            return Data(converting: val)
        case .double(let val):
            return Data(converting: val)
        case .bool(let val):
            return Data(converting: val)
        case .null:
            return nil
        }
    }
}

extension Data {
    fileprivate init<T>(converting value: T) {
        var value = value
        self = Data(bytes: &value, count: MemoryLayout<T>.size)
    }
}

// MARK: Comparable

extension JSON: Comparable {
    public static func < (lhs: JSON, rhs: JSON) -> Bool {
        switch lhs {
        case .int(let val):
            guard
                let r = rhs.int
                else { fatalError("can't compare int w non-int") }
            return val < r
        case .double(let val):
            guard
                let r = rhs.double
                else { fatalError("can't compare double w non-double") }
            return val < r
        case .str(let val):
            guard
                let r = rhs.string
                else { fatalError("can't compare string w non-string") }
            return val < r
        default:
            fatalError("can not compare invalid values: \(lhs) < \(rhs)")
        }
    }
}

