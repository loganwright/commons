import Foundation
import Commons

public typealias NetworkResult = Result<NetworkResponse, Error>
public typealias NetworkCompletion = (NetworkResult) -> Void

public struct NetworkResponse: Codable {
    @ArchivableCodable
    public fileprivate(set) var http: HTTPURLResponse
    public fileprivate(set) var body: Data?
}

extension NetworkResponse {
    /// if the response is valid json, accessible here
    ///
    /// WARNING: this can be expensive due to serialization
    /// conversions.
    ///
    /// Do NOT:
    ///
    ///     // ***** NO *****
    ///     resp.json.a = "some thing"
    ///     resp.json.b = 123
    ///     ..
    ///
    ///Do:
    ///
    ///     var modifying = resp.json
    ///     modifying.a = "some thing"
    ///     modifying.b = 123
    ///     ..
    ///
    /// the second example will have CONSIDERABLY lighter
    /// workload
    ///
    public var json: JSON? {
        get {
            catching { try body?.decode() }
        }
        set {
            body = catching { try newValue.encode() }
        }
    }
    
    /// uses Foundation json parsing to get the contents
    /// of the response's body
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

extension NetworkResponse: CustomStringConvertible {
    public var description: String {
        let msg = body.flatMap { String(bytes: $0, encoding: .utf8) ?? "Data(\($0.count))" } ?? "<no-body>"
        return """
        NetworkResponse:
        \(http)

        Body:
        \(msg)
        """
    }
}

/// should be nested in below extension
/// but not supported generics outside of declaration
private struct ResultMap: Codable {
    var success: NetworkResponse? = nil
    private var archivedFailure: ArchivableCodable<NSError>? = nil
    
    var failure: NSError? {
        get {
            archivedFailure?.wrappedValue
        }
        set {
            archivedFailure = newValue.flatMap(ArchivableCodable.init)
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
