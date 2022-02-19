import Foundation
import Commons

public typealias NetworkResult = Result<NetworkResponse, Error>
public typealias NetworkCompletion = (NetworkResult) -> Void


@propertyWrapper
@dynamicMemberLookup
public struct Archivable<T>: Codable where T: NSObject, T: NSCoding {
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

public struct NetworkResponse: Codable {
    @Archivable
    public fileprivate(set) var http: HTTPURLResponse
    public fileprivate(set) var body: Data?

    public var anyobj: AnyObject? {
        do {
            return try body.flatMap {
                try JSONSerialization.jsonObject(with: $0, options: [])
            } as AnyObject?
        } catch {
            Log.error("failed to serialize object: \(error) body: \(body?.string ?? "<>")")
            return nil
        }
    }
}

extension NetworkResponse {
    public var json: JSON? {
        catching { try body?.decode() }
    }
    
    public mutating func replaceBody(with: JSON) {
        body = catching { try with.encoded() }
    }
}

public func catching<U>(fileID: String = #fileID, line: Int = #line, function: String = #function, _ throwable: () throws -> U?) -> U? {
    do {
        return try throwable()
    } catch {
        Log.error(fileID: fileID, line: line, function: function, error)
        return nil
    }
}


extension NetworkResponse: CustomStringConvertible {
    public var description: String {
        let msg = body.flatMap { String(bytes: $0, encoding: .utf8) } ?? "<no-body>"
        return """
        NetworkResponse:
        \(http)

        Body:
        \(msg)
        """
    }
}


public struct NNNNResponse {
    public let http: HTTPURLResponse
    public let result: Result<Data, Error>
    
    
    public init(_ response: URLResponse?, body: Data?, error: Error?) throws {
        guard let http = response as? HTTPURLResponse else { throw "unable to make http url response: \(response as Any?)" }
        self.http = http
        if http.isSuccessResponse {
            let desc = error ?? body.flatMap(\.string) ?? "no error or response received"
            let err = NSError(domain: NSURLErrorDomain,
                              code: http.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: desc])
            self.result = .failure(err)
        } else {
            self.result = .success(body ?? Data())
            
        }
    }
}

/// should be nested in below extension
/// but not supported generics outside of declaration
private struct ResultMap: Codable {
    var success: NetworkResponse? = nil
    private var archivedFailure: Archivable<NSError>? = nil
    
    var failure: NSError? {
        get {
            archivedFailure?.wrappedValue
        }
        set {
            archivedFailure = newValue.flatMap(Archivable.init)
        }
    }
}

extension Result: Codable where Success == NetworkResponse, Failure == Error {
    public init(from decoder: Decoder) throws {
        let map = try ResultMap(from: decoder)
        if let value = map.success {
            self = .success(value)
        } else if let error = map.failure {
            self = .failure(error)
        } else {
            throw "invalid empty map found"
        }
    }
    public func encode(to encoder: Encoder) throws {
        var map = ResultMap()
        switch self {
        case .success(let success):
            map.success = success
        case .failure(let failure):
            map.failure = failure as NSError
        }
        try map.encode(to: encoder)
    }
}

extension Result where Success == NetworkResponse, Failure == Error {
    public var resp: NetworkResponse? {
        guard case .success(let resp) = self else { return nil }
        return resp
    }

    public init(_ response: HTTPURLResponse?, body: Data?, error: Error?) {
        if let http = response, http.isSuccessResponse {
            self = .success(.init(http: http, body: body))
        } else {
            let desc = error?.display ?? body.flatMap(\.string) ?? "no error or response received"
            let err = NSError(statusCode: response?.statusCode, desc)
            self = .failure(err)
        }
    }
}

fileprivate extension NSError {
    convenience init(statusCode: Int?, _ desc: String) {
        self.init(domain: NSURLErrorDomain,
                  code: statusCode ?? -1,
                  userInfo: [NSLocalizedDescriptionKey: desc])
    }
}

//extension Dictionary where Key == String, Value == String {
//    fileprivate func combined(with rhs: Dictionary?, overwrite: Bool = true) -> Dictionary {
//        var combo = self
//        rhs?.forEach { k, v in
//            guard overwrite || combo[k] == nil else { return }
//            combo[k] = v
//        }
//        return combo
//    }
//}

extension URLRequest {
    public mutating func setBody(json: Data) {
        httpBody = json
        setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}


extension HTTPURLResponse {
    /// set by the registration and metadata server
    public var statusMessage: String? {
        return allHeaderFields["StatusMessage"] as? String
    }

    /// the standardized message associated with the given status code, localized
    public var standardizedLocalizedStatusMessage: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }

    public var isSuccessResponse: Bool {
        return (200...299).contains(statusCode) || statusCode == 0
    }
}

// MARK: Result

extension Result where Success == NetworkResponse {
    public func unwrap<D: Decodable>(as: D.Type) throws -> D {
        switch self {
        case .success(let resp):
            guard let body = resp.body
                else { throw "expected data on response: \(resp.http)" }
            return try D.decode(body)
        case .failure(let error):
            throw error
        }
    }

    public func map<D: Decodable>(to completion: @escaping (Result<D, Error>) -> Void) {
        do {
            let ob = try self.unwrap(as: D.self)
            completion(.success(ob))
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: Decoding

extension Decodable {
    public static func decode(_ resp: NetworkResponse) throws -> Self {
        guard let body = resp.body else { throw "expected to find body to decode" }
        return try decode(body)
    }
}
