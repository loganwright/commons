import Foundation

// MARK: Codable

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

// MARK: Data

extension Data {
    public func decode<D: Decodable>(_ type: D.Type = D.self,
                                     strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> D {
        try D.decode(self)
    }
}

// MARK: Conversions

extension Encodable {
    /// these methods are likely not super performant
    /// but they are a convenient way to exchange between
    /// any codable types using JSON as a medium
    ///
    /// if the entire object isn't coded, it may lose data
    ///
    /// things such as out of order dictionaries may still happen
    public func convert<D: Decodable>(to: D.Type = D.self) throws -> D {
        try self.encode().decode()
    }
}

extension Decodable {
    public static func convert<E: Encodable>(from: E) throws -> Self {
        try from.encode().decode()
    }
}
