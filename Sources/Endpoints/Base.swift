import Foundation
import Commons

extension String {
    fileprivate var urlcomponents: URLComponents {
        URLComponents(string: self)!
    }
}
extension URLComponents {
    fileprivate var baseUrl: String {
        scheme! + "://" + host!
    }
    
    fileprivate var _query: JSON? {
        guard let items = queryItems else { return nil }
        var obj = [String: JSON]()
        items.forEach { item in
            obj[item.name] = item.value.flatMap(JSON.string) ?? .null
        }
        return .object(obj)
    }
}

extension URLSession: Client {
    public func send(_ request: URLRequest, completion: @escaping NetworkCompletion) {
        self.dataTask(with: request) { (data, response, error) in
            main {
                completion(.init(response as? HTTPURLResponse, body: data, error: error))
            }
        }
        .resume()
    }
}

public protocol Client {
    func send(_ request: URLRequest, completion: @escaping NetworkCompletion)
}

@dynamicMemberLookup
public class Base {
    
    /// the root url to append to
    public private(set) var baseUrl: String
    public var _method: HTTPMethod = .get
    public var _path: String = ""
    public var _headers: [String: String] = [:]
    public var _query: JSON? = nil
    public var _body: JSON? = nil
    private var _timeout: TimeInterval = 30.0

    public init(_ url: String) {
        let comps = url.urlcomponents
        self.baseUrl = comps.baseUrl
        self._path = comps.path
        self._query = comps._query
    }

    // MARK: PathBuilder

    /// add keys to EP in an extension to support
    public subscript(dynamicMember key: KeyPath<Endpoint, Endpoint>) -> PathBuilder {
        let ep = Endpoint("")[keyPath: key]
        _path += ep.stringValue
        let builder = PathBuilder(self, startingPath: _path)
        return builder
    }

    /// for better building
    public subscript(dynamicMember key: KeyPath<Endpoint, Endpoint>) -> Self {
        let ep = Endpoint("")[keyPath: key]
        _path += ep.stringValue
        return self
    }

    /// get, post, put, patch, delete
    public subscript(dynamicMember key: KeyPath<PathBuilder, HTTPMethod>) -> PathBuilder {
        let builder = PathBuilder(self, startingPath: _path)
        self._method = builder[keyPath: key]
        return builder
    }

    /// get, post, put, patch, delete
    public subscript(dynamicMember key: KeyPath<PathBuilder, HTTPMethod>) -> Self {
        let builder = PathBuilder(self)
        self._method = builder[keyPath: key]
        return self
    }

    fileprivate func set(path: String) -> Self {
        self._path = path
        return self
    }

    // MARK: HeadersBuilder

    public var header: HeadersBuilder { HeadersBuilder(self) }

    fileprivate func set(header: String, _ v: String) -> Self {
        self._headers[header] = v
        return self
    }

    public subscript(dynamicMember key: KeyPath<HeaderKey, String>) -> HeadersBuilderExistingKey {
        let headerKey = HeaderKey(stringLiteral: "")[keyPath: key]
        return .init(self, key: headerKey)
    }

    // MARK: BodyBuilder

    public var query: ObjBuilder {
        if _method != .get {
            // in practice however, it's a bit different
            Log.warn("query is traditionally disallowed on anything but a `get` request")
        }
        return ObjBuilder(self, kp: \._query)
    }

    public var body: ObjBuilder {
        ObjBuilder(self, kp: \._body)
    }

    // MARK: Handlers

    /// idk if I like this syntax or the other
    public var on: OnBuilder { OnBuilder(self) }

    // MARK: Middleware

    private var middlewares: [Middleware] = []

    // TODO: sort by priority Int?
    public enum MiddlewareInsert {
        case front
        case back
    }

    public func middleware(_ middleware: Middleware, to: MiddlewareInsert = .back) -> Self {
        switch to {
        case .front:
            self.middlewares.insert(middleware, at: 0)
        case .back:
            self.middlewares.append(middleware)
        }
        return self
    }

    public func drop(middleware matching: (Middleware) -> Bool) -> Self {
        middlewares.removeAll(where: matching)
        return self
    }
    
    private var _beforeOps: [(inout URLRequest) -> Void] = []
    public func beforeSend(_ op: @escaping () -> Void) -> Self {
        beforeSend({ _ in op() })
    }
    
    public func beforeSend(_ op: @escaping (inout URLRequest) -> Void) -> Self {
        _beforeOps.append(op)
        return self
    }
    
    public func client(_ client: Client) -> Self {
        self.networkClient = client
        return self
    }

    // MARK: Send

    // TODO: use a beforeRun or middleware or sth
    public var _logging = false

    public func send() {
        if _logging { Log.info("requesting: \(expandedUrl)") }

        let queue = self.middlewares.reversed().reduce(onComplete) { (result, next) in
            return { res in
                next.handle(res, next: result)
            }
        } as NetworkCompletion

        guard Network.isAvailable else {
            queue(.failure(NSError.noNetwork))
            return
        }

        do {
            var request = try makeRequest()
            _beforeOps.forEach { op in op(&request) }
            networkClient.send(request, completion: queue)
        } catch {
            queue(.failure(error))
        }
    }
    
    public var networkClient: Client = URLSession(configuration: .default)

    public func makeRequest() throws -> URLRequest {
        guard let url = URL(string: expandedUrl) else {
            throw "can't make url from: \(expandedUrl)"
        }
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: _timeout)
        request.allHTTPHeaderFields = _headers
        request.httpMethod = _method.rawValue
        if _method == .get, _body != nil {
            Log.warn("body sometimes ignored on GET request")
        }
        
        if _method != .get, let body = _body {
            let body = try body.encode()
            request.setBody(json: body)
        }
        return request
    }

    public var expandedUrl: String {
        var url = self.baseUrl.withTrailingSlash
        if _path.hasPrefix("/") {
            url += _path.dropFirst()
        } else {
            url += _path
        }
        
        if _method != .get, _query != nil {
            Log.warn("non-get requests may not support query params")
        }
        guard let query = _query else { return url }
        return url + "?" + makeQueryString(parameters: query)
    }


    enum QueryArrayEncodingStrategy {
        case commaSeparated, multiKeyed
    }
    let queryArrayEncodingStrategy: QueryArrayEncodingStrategy = .commaSeparated

    func makeQueryString(parameters: JSON) -> String {
        guard let object = parameters.object else {
            fatalError("object required for query params")
        }
        switch queryArrayEncodingStrategy {
        case .multiKeyed:
            return makeMultiKeyedQuery(object: object)
        case .commaSeparated:
            return makeCommaSeparatedQuery(object: object)
        }
    }

    private func makeCommaSeparatedQuery(object: [String: JSON]) -> String {
        let query = object
            .map { key, val in
                let entry = val.array?.compactMap(\.string).joined(separator: ",") ?? val.string ?? ""
                return key + "=\(entry)"
            }
            .sorted(by: <)
            .joined(separator: "&")

        // todo: fallback to percent fail onto original query
        // verify ideal behavior
        return query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? query
    }

    private func makeMultiKeyedQuery(object: [String: JSON]) -> String {
        var params: [(key: String, val: String)] = []
        object.forEach { k, v in
            if let array = v.array {
                array.map(\.string!).forEach { v in
                    params.append((k, v))
                }
            } else {
                params.append((k, v.string!))
            }
        }

        let query = params.map { param in param.key + "=\(param.val)" }
            .sorted(by: <)
            .joined(separator: "&")
        // todo: fallback to percent fail onto original query
        // verify ideal behavior
        return query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? query
    }

    private(set) var done = false
    private func onComplete(_ result: Result<NetworkResponse, Error>) {
        done = true
    }

    /// looks a little funny, but enables logging
    var logging: Self {
        _logging = true
        let path = self._path.withTrailingSlash
        return on.result { result in
            switch result {
            case .success(let resp):
                Log.info("request.succeeded: \(path)" + "\n\(resp)")
            case .failure(let err):
                Log.error("request.failed: \(path), error: \(err)")
            }
        } as! Self
    }
}

// MARK: ObjBuilder

@dynamicCallable
public class ObjBuilder {
    public let base: Base
    public let kp: ReferenceWritableKeyPath<Base, JSON?>
    
    fileprivate init(_ base: Base, kp: ReferenceWritableKeyPath<Base, JSON?>) {
        self.base = base
        self.kp = kp
    }

    public func dynamicallyCall<T: Encodable>(withArguments args: [T]) -> Base {
        let body: JSON
        if args.isEmpty {
            body = [:]
        } else if args.count == 1 {
            body = try! args[0].convert()
        } else {
            body = try! args.convert()
        }
        base[keyPath: kp] = body
        return base
    }

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) -> Base {
        let body = JSON(args)
        base[keyPath: kp] = body
        return base
    }
}

// MARK: Path Builder

@dynamicCallable
@dynamicMemberLookup
public class PathBuilder {
    public var get: HTTPMethod = .get
    public var post: HTTPMethod = .post
    public var put: HTTPMethod = .put
    public var patch: HTTPMethod = .patch
    public var delete: HTTPMethod = .delete

    public let base: Base
    private let startingPath: String?

    fileprivate init(_ base: Base, startingPath: String? = nil) {
        self.base = base
        self.startingPath = startingPath
    }

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) -> Base {
        var updated: String = ""
        if let starting = startingPath {
            updated = starting
        }

        if let arg = args.first, arg.key.isEmpty || arg.key == "path" {
            assert(args.count >= 1)
            let arg = args[0]
            assert(arg.key.isEmpty || arg.key == "path",
                   "first arg should be path string with no label, or (path: ")
            updated += arg.value as! String
        }

        args.forEach { entry, replacement in
            guard !entry.isEmpty && entry != "path" else { return }
            let wrapped = "{\(entry)}"
            let replacement = "\(replacement)"
            updated.replaceFirstOccurence(of: wrapped, with: replacement)
        }

        return base.set(path: updated)
    }

    /// sometimes we do like `.get("path")`, sometimes we just do like `get.on(success:)`
    public subscript<T>(dynamicMember key: KeyPath<Base, T>) -> T {
        base[keyPath: key]
    }
}

extension String {
    fileprivate mutating func replaceFirstOccurence(of entry: String, with: String) {
        guard let range = self.range(of: entry) else {
            Log.warn("no occurence of \(entry) in \(self)")
            return
        }
        self.replaceSubrange(range, with: with)
    }
}

// MARK: Handler Builder

open class OnBuilder {
    public let base: Base

    fileprivate init(_ base: Base) {
        self.base = base
    }

    public func success(_ success: @escaping () -> Void) -> Base {
        base.middleware(BasicHandler(onSuccess: success))
    }

    public func success(_ success: @escaping (NetworkResponse) -> Void) -> Base {
        base.middleware(BasicHandler(onSuccess: success))
    }

    public func success<D: Decodable>(_ success: @escaping (D) -> Void) -> Base {
        base.middleware(BasicHandler(onSuccess: success))
    }

    public func error(_ error: @escaping () -> Void) -> Base {
        base.middleware(BasicHandler(onError: { _ in error() }))
    }

    public func error(_ error: @escaping (Error) -> Void) -> Base {
        base.middleware(BasicHandler(onError: error))
    }

    public func result(_ result: @escaping (Result<NetworkResponse, Error>) -> Void) -> Base {
        base.middleware(BasicHandler(basic: result))
    }

    public func either(_ run: @escaping (Result<NetworkResponse, Error>) -> Void) -> Base {
        result(run)
    }

    public func either(_ run: @escaping () -> Void) -> Base {
        base.middleware(BasicHandler(basic: { _ in run() }))
    }
}

public struct TypedOnBuilder<D: Decodable> {
    public let base: Base

    init(_ base: Base) {
        self.base = base
    }

    // todo: make `OnBuilder` a function builder w
    // enums for state and use properties so these can pass through

    public func success(_ success: @escaping (D) -> Void) -> TypedBuilder<D> {
        base.middleware(BasicHandler(onSuccess: success)).typed()
    }

    public func success(_ success: @escaping () -> Void) -> TypedBuilder<D> {
        base.middleware(BasicHandler(onSuccess: success)).typed()
    }

    public func error(_ error: @escaping () -> Void) -> TypedBuilder<D> {
        base.middleware(BasicHandler(onError: { _ in error() })).typed()
    }

    public func error(_ error: @escaping (Error) -> Void) -> TypedBuilder<D> {
        base.middleware(BasicHandler(onError: error)).typed()
    }

    public func either(_ runner: @escaping (Result<D, Error>) -> Void) -> TypedBuilder<D> {
        base.on.result { $0.map(to: runner) }.typed()
    }

    public func either(_ run: @escaping () -> Void) -> TypedBuilder<D> {
        base.middleware(BasicHandler(basic: { _ in run() })).typed()
    }

    public func result(_ result: @escaping (Result<NetworkResponse, Error>) -> Void) -> TypedBuilder<D> {
        base.on.result(result).typed()
    }
}

public struct TypedBuilder<D: Decodable> {
    public let base: Base

    init(_ base: Base) {
        self.base = base
    }

    public var on: TypedOnBuilder<D> { .init(base) }

    public func send() { base.send() }

    // is this needed?
    public var detyped: Base { base }
}

extension Base {
    public func typed<D: Decodable>(as: D.Type = D.self) -> TypedBuilder<D> {
        .init(self)
    }
}

// MARK: Headers Builder

public final class HeadersBuilderExistingKey {
    public let key: String
    private let base: Base

    fileprivate init(_ base: Base, key: String) {
        self.base = base
        self.key = key
    }

    public func callAsFunction(_ val: String) -> Base {
        return base.set(header: key, val)
    }
}

@dynamicMemberLookup
public final class HeadersBuilder {
    public let base: Base

    fileprivate init(_ base: Base) {
        self.base = base
    }

    public func callAsFunction(_ key: String, _ val: String) -> Base {
        return base.set(header: key, val)
    }

    public subscript(dynamicMember key: KeyPath<HeaderKey, String>) -> HeadersBuilderExistingKey {
        let headerKey = HeaderKey(stringLiteral: "")[keyPath: key]
        return .init(base, key: headerKey)
    }
}

extension Base {
    public var logErrors: Base {
        on.error { error in
            Log.error(error)
        }
    }
}


//#if canImport(XCTest)
//import XCTest
//
//extension TypedBuilder {
//    public func testing(on expectation: XCTestExpectation) -> Self {
//        self.base.testing(on: expectation).typed()
//    }
//}
//
//extension Base {
//    public func testing(on expectation: XCTestExpectation) -> Base {
//        self.on.either(expectation.fulfill)
//            .on.error { err in
//                XCTFail("\(err)")
//            }
//    }
//}
//
//#endif
