import Foundation
import Commons

// MARK: Network Client

public protocol Client {
    func send(_ request: URLRequest, completion: @escaping NetworkCompletion)
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

// MARK: BaseWrapper

@dynamicMemberLookup
public protocol BaseWrapper {
    var wrapped: Base { get }
}

extension Base: BaseWrapper {
    public var wrapped: Base { self }
}

extension TypedBuilder: BaseWrapper {
    public var wrapped: Base { base }
}

extension BaseWrapper {
    // MARK: Base Accessors
    
    subscript<T>(dynamicMember kp: KeyPath<Base, T>) -> T {
        wrapped[keyPath: kp]
    }

    subscript<T>(dynamicMember kp: WritableKeyPath<Base, T>) -> T {
        wrapped[keyPath: kp]
    }
    
    // MARK: Path Building
    
    /// add keys to EP in an extension to support
    public subscript(dynamicMember key: KeyPath<Endpoint, Endpoint>) -> PathBuilder<Self> {
        let ep = Endpoint("")[keyPath: key]
        wrapped._path += ep.stringValue
        return PathBuilder(self, startingPath: wrapped._path)
//        return builder
    }

    /// for better building
    public subscript(dynamicMember key: KeyPath<Endpoint, Endpoint>) -> Self {
        let ep = Endpoint("")[keyPath: key]
        wrapped._path += ep.stringValue
        return self
    }
    
    /// get, post, put, patch, delete
    public subscript(dynamicMember key: KeyPath<HTTPMethods, HTTPMethod>) -> PathBuilder<Self> {
        wrapped._method = HTTPMethods.group[keyPath: key]
        return PathBuilder(self, startingPath: wrapped._path)
    }

    /// get, post, put, patch, delete
    public subscript(dynamicMember key: KeyPath<HTTPMethods, HTTPMethod>) -> Self {
        wrapped._method = HTTPMethods.group[keyPath: key]
        return self
    }
    
    // MARK: Headers
    
    public var h: HeadersBuilder<Self> { HeadersBuilder(self) }
    public var header: HeadersBuilder<Self> { HeadersBuilder(self) }
    
    public subscript(dynamicMember key: KeyPath<HeaderKey, HeaderKey>) -> HeadersBuilderExistingKey<Self> {
        let headerKey = HeaderKey(stringLiteral: "")[keyPath: key]
        return .init(self, key: headerKey.stringValue)
    }
    
    // MARK: Body/Query
    
    /// used to build the query of the request
    /// dynamically, ie: `.query(key: val, key: 2)`
    public var query: ObjBuilder<Self> {
        if wrapped._method != .get {
            // in practice however, it's a bit different
            Log.warn("query is traditionally disallowed on anything but a `get` request")
        }
        return ObjBuilder(self, kp: \.wrapped._query)
    }

    /// used to build the body of the request
    /// dynamically, ie: `.body(dynamic: "keys here")`
    /// or `.body(entireObject)`
    public var body: ObjBuilder<Self> {
        ObjBuilder(self, kp: \.wrapped._body)
    }
}

// MARK: Middlewares

public enum MiddlewareInsert {
    case front
    case back
}

extension BaseWrapper {
    public func middleware(_ middleware: Middleware, to: MiddlewareInsert = .back) -> Self {
        switch to {
        case .front:
            wrapped.middlewares.insert(middleware, at: 0)
        case .back:
            wrapped.middlewares.append(middleware)
        }
        return self
    }

    public func drop(middleware matching: (Middleware) -> Bool) -> Self {
        wrapped.middlewares.removeAll(where: matching)
        return self
    }
}

// MARK: Before Hooks

extension BaseWrapper {
    public func beforeSend(_ op: @escaping () -> Void) -> Self {
        beforeSend({ _ in op() })
    }
    
    public func beforeSend(_ op: @escaping (inout URLRequest) -> Void) -> Self {
        wrapped.beforeSends.append(op)
        return self
    }
    
    public func client(_ client: Client) -> Self {
        wrapped.networkClient = client
        return self
    }
}

// MARK: Responders

extension BaseWrapper {
    public func send() {
        wrapped.send()
    }
}

extension BaseWrapper { // where Self: Base {
    public var on: OnBuilder<Self, JSON> {
        OnBuilder(self)
    }
}

extension TypedBuilder {
    public var on: OnBuilder<Self, D> {
        OnBuilder(self)
    }
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
    
    /// submit url requests
    ///
    public var middlewares: [Middleware] = []
    public var beforeSends: [(inout URLRequest) -> Void] = []
    public var networkClient: Client = URLSession(configuration: .default)

    public init(_ url: String) {
        let comps = url.urlcomponents
        self.baseUrl = comps.baseUrl
        self._path = comps.path
        self._query = comps._query
    }

    // MARK: Send
    
    public func send() {
        let responderChain = makeResponderChain()
        guard Network.isAvailable else {
            responderChain(.failure(NSError.noNetwork))
            return
        }

        do {
            var request = try makeRequest()
            beforeSends.forEach { op in op(&request) }
            networkClient.send(request, completion: responderChain)
        } catch {
            responderChain(.failure(error))
        }
    }

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

    // MARK: Query

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

    // MARK: Responder Chain
    
    private(set) var done = false
    private func onComplete(_ result: Result<NetworkResponse, Error>) {
        done = true
    }
    
    /// combines all of the middleware into a single closure chain
    public func makeResponderChain() -> NetworkCompletion {
        self.middlewares.reversed().reduce(onComplete) { (result, next) in
            return { res in
                next.handle(res, next: result)
            }
        } as NetworkCompletion
    }
    
}

// MARK: ObjBuilder

@dynamicCallable
public class ObjBuilder<Wrapped: BaseWrapper> {
    public let base: Wrapped
    public let kp: ReferenceWritableKeyPath<Base, JSON?>
    
    fileprivate init(_ backing: Wrapped, kp: ReferenceWritableKeyPath<Base, JSON?>) {
        self.base = backing
        self.kp = kp
    }
    
    public func dynamicallyCall<T: Encodable>(withArguments args: [T]) -> Wrapped {
        let body: JSON
        if args.isEmpty {
            body = [:]
        } else if args.count == 1 {
            body = try! args[0].convert()
        } else {
            body = try! args.convert()
        }
        base.wrapped[keyPath: kp] = body
        return base
    }

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) -> Wrapped {
        let body = JSON(args)
        base.wrapped[keyPath: kp] = body
        return base
    }
}

// MARK: Path Builder

@dynamicCallable
@dynamicMemberLookup
public class PathBuilder<Wrapper: BaseWrapper> {
    public var get: HTTPMethod = .get
    public var post: HTTPMethod = .post
    public var put: HTTPMethod = .put
    public var patch: HTTPMethod = .patch
    public var delete: HTTPMethod = .delete

    public let base: Wrapper
    private let startingPath: String?

    fileprivate init(_ base: Wrapper, startingPath: String? = nil) {
        self.base = base
        self.startingPath = startingPath
    }

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) -> Wrapper {
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

        base.wrapped._path = updated
        return base
    }

    /// sometimes we do like `.get("path")`, sometimes we just do like `get.on(success:)`
    public subscript<T>(dynamicMember key: KeyPath<BaseWrapper, T>) -> T {
        base[keyPath: key]
    }
}

// MARK: Handler Builder

public struct OnBuilder<Wrapped: BaseWrapper, D: Decodable> {
    public let base: Wrapped

    init(_ base: Wrapped) {
        self.base = base
    }

    public func success(_ success: @escaping () -> Void) -> Wrapped {
        base.middleware(BasicHandler(onSuccess: success))
    }

    public func success(_ success: @escaping (D) -> Void) -> Wrapped {
        base.middleware(BasicHandler(onSuccess: success))
    }

    public func error(_ error: @escaping () -> Void) -> Wrapped {
        base.middleware(BasicHandler(onError: { _ in error() }))
    }

    public func error(_ error: @escaping (Error) -> Void) -> Wrapped {
        base.middleware(BasicHandler(onError: error))
    }

    public func either(_ run: @escaping () -> Void) -> Wrapped {
        base.middleware(BasicHandler(basic: { _ in run() }))
    }

    public func either(_ runner: @escaping (Result<D, Error>) -> Void) -> Wrapped {
        base.middleware(BasicHandler(basic: { $0.map(to: runner) }))
    }

    public func result(_ result: @escaping (Result<NetworkResponse, Error>) -> Void) -> Wrapped {
        base.middleware(BasicHandler(basic: result))
    }
}

/// carries an inherent type
@dynamicMemberLookup
public struct TypedBuilder<D: Decodable> {
    public let base: Base

    init(_ base: Base) {
        self.base = base
    }

    // is this needed?
    public var detyped: Base { base }
}

extension BaseWrapper {
    public func typed<D: Decodable>(as: D.Type = D.self) -> TypedBuilder<D> {
        .init(wrapped)
    }
}

// MARK: Headers Builder

public final class HeadersBuilderExistingKey<Wrapper: BaseWrapper> {
    public let key: String
    private let base: Wrapper

    fileprivate init(_ base: Wrapper, key: String) {
        self.base = base
        self.key = key
    }
    
    public func callAsFunction(_ val: String) -> Wrapper {
        base.wrapped._headers[key] = val
        return base
    }
}

@dynamicMemberLookup
public final class HeadersBuilder<Wrapper: BaseWrapper> {
    public let base: Wrapper

    fileprivate init(_ base: Wrapper) {
        self.base = base
    }

    public func callAsFunction(_ key: String, _ val: String) -> Wrapper {
        base.wrapped._headers[key] = val
        return base
    }

    public subscript(dynamicMember key: KeyPath<HeaderKey, HeaderKey>) -> HeadersBuilderExistingKey<Wrapper> {
        let headerKey = HeaderKey(stringLiteral: "")[keyPath: key]
        return .init(base, key: headerKey.stringValue)
    }
}

extension BaseWrapper {
    public var logErrors: Self {
        self.on.error { error in
            Log.error(error)
        }
    }
}

// MARK: String Helpers

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

extension String {
    fileprivate mutating func replaceFirstOccurence(of entry: String, with: String) {
        guard let range = self.range(of: entry) else {
            Log.warn("no occurence of \(entry) in \(self)")
            return
        }
        self.replaceSubrange(range, with: with)
    }
}
