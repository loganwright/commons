import Foundation

extension JSON {
    public var any: AnyObject? {
        switch self {
        case .int(let val):
            return val as AnyObject
        case .double(let val):
            return val as AnyObject
        case .str(let val):
            return val as AnyObject
        case .bool(let val):
            return val as AnyObject
        case .obj(let val):
            var any: [String: Any] = [:]
            val.forEach { k, v in
                any[k] = v.any
            }
            return any as AnyObject
        case .array(let val):
            return val.map { $0.any ?? NSNull() } as AnyObject
        case .null:
            return nil
        }
    }
}

extension JSON {
    public init(fuzzy: Any) throws {
        if let data = fuzzy as? Data {
            self = try data.decode()
        } else if let e = fuzzy as? Encodable {
            self = try e.convert()
        } else if let nsobj = fuzzy as? NSObject {
            self = try JSON(nsobj: nsobj)
        } else {
            throw "unknown type: \(type(of: fuzzy))"
        }
    }

    public init(nsobj: NSObject) throws {
        if let dict = nsobj as? NSDictionary {
            var obj = JSON.emptyObj
            try dict.forEach { k, v in
                obj["\(k)"] = try .init(fuzzy: v)
            }
            self = obj
        } else if let array = nsobj as? NSArray {
            self = try .array(array.map(JSON.init(fuzzy:)))
        } else {
            let serialized = try! JSONSerialization.data(
                withJSONObject: nsobj,
                options: [.fragmentsAllowed])

            self = try serialized.decode()
        }
    }
}

extension JSON {
    public init(_ kvp: KeyValuePairs<String, Any>) {
        var ob = JSON.emptyObj
        kvp.forEach { k, v in
            do {
                ob[k] = try JSON(fuzzy: v)
            } catch {
                Log.error(error)
                Log.info("unable to serialize: \(type(of: v)): \(v)")
            }
        }
        self = ob
    }
}

