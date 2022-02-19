import Foundation

extension Data {
    public func decode<D: Decodable>(_ type: D.Type = D.self,
                                     strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> D {
        try D.decode(self)
    }
}

extension Decodable {
    public static func decode(_ data: Data, strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> Self {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = strategy
        return try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {
    public func encode(pretty: Bool = false, strategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) throws -> Data {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        return try encoder.encode(self)
    }
}

// MARK: Conversions

extension Encodable {
    func convert<D: Decodable>(to: D.Type = D.self) throws -> D {
        try self.encode().decode()
    }
}

extension Decodable {
    static func convert<E: Encodable>(from: E) throws -> Self {
        try from.encode().decode()
    }
}

//extension Encodable {
//    public var anyobj: AnyObject? {
//        /// we could probably take some of this out, it was originally stitching for other systems to transition with
//        let data = try? self.encoded()
//        let json = data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
//        return json as AnyObject?
//    }
//}
