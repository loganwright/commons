import Foundation

extension JSON {
    public static let empty: JSON = .object([:])
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
    case string(String)
    case bool(Bool)
    case null
    case array([JSON])
    case object([String: JSON])

    public init(from decoder: Decoder) throws {
        if let val = try? Int.init(from: decoder) {
            self = .int(val)
        } else if let val = try? Double(from: decoder) {
            self = .double(val)
        } else if let val = try? String(from: decoder) {
            self = .string(val)
        } else if let val = try? Bool(from: decoder) {
            self = .bool(val)
        } else if let isNil = try? decoder.singleValueContainer().decodeNil(), isNil {
            self = .null
        } else if let val = try? [String: JSON](from: decoder) {
            self = .object(val)
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
        case .string(let val):
            try val.encode(to: encoder)
        case .bool(let val):
            try val.encode(to: encoder)
        case .object(let val):
            try val.encode(to: encoder)
        case .array(let val):
            try val.encode(to: encoder)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
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
            return .string(s)
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
                    return .string(str)
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
        case .string(let s): return Int(s)
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
        case .string(let s): return Double(s)
        case .bool(let b): return b ? 1 : 0
        default: return nil
        }
    }
    
    public var string: String? {
        switch self {
        case .int(let val): return val.description
        case .double(let val): return val.description
        case .string(let val): return val
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
        case .string(let s):
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

    public var object: [String: JSON]? {
        switch self {
        case .object(let v):
            return v
        case .string(let str):
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
        case .string(let str):
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
    ///
    /// I named it a bit weird to discourage use
    public var byteRepresentation: Data? {
        switch self {
        case .string(let val):
            return Data(val.utf8)
        case .array(let arr):
            return catching { try arr.encode() }
        case .object(let obj):
            return catching { try obj.encode() }
        case .int(let val):
            return Data(byteRepresentationOf: val)
        case .double(let val):
            return Data(byteRepresentationOf: val)
        case .bool(let val):
            return Data(byteRepresentationOf: val)
        case .null:
            return nil
        }
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
        case .string(let val):
            guard
                let r = rhs.string
                else { fatalError("can't compare string w non-string") }
            return val < r
        default:
            fatalError("can not compare invalid values: \(lhs) < \(rhs)")
        }
    }
}

