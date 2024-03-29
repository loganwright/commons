import Foundation
import Commons

// MARK: Network Client

public protocol Client {
    func send(_ request: URLRequest, completion: @escaping NetworkCompletion)
}

extension URLSession: Client {
    public func send(_ request: URLRequest, completion: @escaping NetworkCompletion) {
        self.dataTask(with: request) { (data, response, error) in
            async.main {
                completion(.init(response as? HTTPURLResponse, body: data, error: error))
            }
        }
        .resume()
    }
}

// MARK: BasicRequest

/// allowing typed and untyped flexibility in parallel
@dynamicMemberLookup
public protocol BasicRequest {
    var wrapped: Root { get }
}

extension Root: BasicRequest {
    public var wrapped: Root { self }
}

extension TypedBuilder: BasicRequest {
    public var wrapped: Root { base }
}

public protocol Request: BasicRequest {
    associatedtype ResponseType: Decodable
}

extension Root: Request {
    public typealias ResponseType = JSON
}

extension TypedBuilder: Request {
    public typealias ResponseType = D
}

@available(iOS 15, *)
extension BasicRequest {
    public func send() async throws -> NetworkResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.on.result(continuation.resume).send()
        }
    }
    
    public func send<D: Decodable>(expecting: D.Type = D.self) async throws -> D {
        try await withCheckedThrowingContinuation { continuation in
            self.typed(as: D.self).on.either(continuation.resume).send()
        }
    }
}

@available(iOS 15, *)
extension Request {
    public func send() async throws -> ResponseType {
        try await withCheckedThrowingContinuation { continuation in
            self.on.either(continuation.resume).send()
        }
    }
}

// MARK: KeyPath Dynamics

extension BasicRequest {
    public subscript<T>(dynamicMember kp: KeyPath<Root, T>) -> T {
        wrapped[keyPath: kp]
    }

    public subscript<T>(dynamicMember kp: ReferenceWritableKeyPath<Root, T>) -> T {
        get {
            wrapped[keyPath: kp]
        }
        set {
            wrapped[keyPath: kp] = newValue
        }
    }
    
    // MARK: Path Building
    
    /// add keys to EP in an extension to support
    public subscript(dynamicMember key: KeyPath<Endpoint, Endpoint>) -> PathBuilder<Self> {
        let ep = Endpoint("")[keyPath: key]
        wrapped._path = wrapped._path.withTrailingSlash + ep.stringValue
        return PathBuilder(self)
    }

    /// for better building
    public subscript(dynamicMember key: KeyPath<Endpoint, Endpoint>) -> Self {
        let ep = Endpoint("")[keyPath: key]
        wrapped._path = wrapped._path.withTrailingSlash + ep.stringValue
        return self
    }
    
    /// get, post, put, patch, delete
    public subscript(dynamicMember key: KeyPath<HTTPMethods, HTTPMethod>) -> PathBuilder<Self> {
        wrapped._method = HTTPMethods.instance[keyPath: key]
        return PathBuilder(self)
    }

    /// get, post, put, patch, delete
    public subscript(dynamicMember key: KeyPath<HTTPMethods, HTTPMethod>) -> Self {
        wrapped._method = HTTPMethods.instance[keyPath: key]
        return self
    }
    
    /// appends the contents as a path component
    ///
    public func id(_ id: CustomStringConvertible, enforceTrailingSlash: Bool = false) -> Self {
        path(id, enforceTrailingSlash: enforceTrailingSlash)
    }
    
    /// appends contents as path component
    ///
    public func path(_ id: CustomStringConvertible, enforceTrailingSlash: Bool = false) -> Self {
        let component: String
        if id.description == "/" {
            component = ""
        } else if enforceTrailingSlash {
            component = id.description.withTrailingSlash
        }  else {
            component = id.description
        }
        wrapped._path = wrapped._path.withTrailingSlash + component
        return self
    }
    
    // MARK: Headers
    
    /// add a header to your request
    public var h: HeadersBuilder<Self> { HeadersBuilder(self) }
    /// add a header to your request
    public var header: HeadersBuilder<Self> { HeadersBuilder(self) }
    
    /// used to set values for predefined header keys
    /// ie:
    ///
    ///     yourRequest
    ///         .yourHeader("some val")
    ///         .yourOtherHeader("some other val")
    ///
    public subscript(dynamicMember key: KeyPath<HeaderKey, HeaderKey>) -> HeadersBuilderExistingKey<Self> {
        let headerKey = HeaderKey(stringLiteral: "")[keyPath: key]
        return .init(self, key: headerKey.stringValue)
    }
    
    // MARK: Body/Query
    
    /// shorthand for query building
    public var q: ObjBuilder<Self> { query }
    
    /// used to build the query of the request
    /// dynamically, ie: `.query(key: val, key: 2)`
    public var query: ObjBuilder<Self> {
        if wrapped._method != .get {
            // in practice however, it's a bit different
            Log.warn("query is traditionally disallowed on anything but a `get` request")
        }
        return ObjBuilder(self, kp: \.wrapped._query)
    }
    
    /// shorthand for body building
    public var b: ObjBuilder<Self> { query }

    /// used to build the body of the request
    /// dynamically, ie: `.body(dynamic: "keys here")`
    /// or `.body(entireObject)`
    public var body: ObjBuilder<Self> {
        ObjBuilder(self, kp: \.wrapped._body)
    }
}

// MARK: Middlewares

extension BasicRequest {
    /// insert a middleware, these will run in order added
    /// calling `front: true` will insert at front of queue
    /// however, if a subsequent call also calls `front: true`
    /// that will be inserted to the front
    public func middleware(_ middleware: Middleware, front: Bool = false) -> Self {
        if front {
            wrapped.middlewares.insert(middleware, at: 0)
        } else {
            wrapped.middlewares.append(middleware)
        }
        return self
    }

    /// remove a middleware
    public func drop(middleware matching: (Middleware) -> Bool) -> Self {
        wrapped.middlewares.removeAll(where: matching)
        return self
    }
}

// MARK: Before Hooks

extension BasicRequest {
    /// sets an operation to run before sending
    public func beforeSend(_ op: @escaping () -> Void) -> Self {
        beforeSend({ _ in op() })
    }
    
    /// sets an operation allowing request modification prior to a send
    public func beforeSend(_ op: @escaping (inout URLRequest) -> Void) -> Self {
        wrapped.beforeSends.append(op)
        return self
    }
}
    
extension BasicRequest {
    /// sets a new client to be used
    public func client(_ client: Client) -> Self {
        wrapped.networkClient = client
        return self
    }
    
    public func encodeQueryArrays(using strategy: Root.QueryArrayEncodingStrategy) -> Self {
        wrapped.queryArrayEncodingStrategy = strategy
        return self
    }
}

// MARK: Responders

extension BasicRequest {
    /// initiate the request over the network
    public func send() {
        wrapped.send()
    }
}

extension BasicRequest {
    /// add responders to the response chain
    ///
    ///     Root.yourApi
    ///         .somePath
    ///         .on.success { }
    ///         .on.error { }
    ///
    /// see: OnBuilder
    /// it is safe to call this many times and pass the response to any number of responders
    /// there is a lot of unoptimized serialization happening which may slow things down
    /// if it becomes too complex
    public var on: OnBuilder<Self, JSON> {
        OnBuilder(self)
    }
}

extension Request {
    public var on: OnBuilder<Self, ResponseType> {
        OnBuilder(self)
    }
}

@dynamicMemberLookup
public class Root {
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
    
    /// if you want your query arrays encoded ie:
    /// (multikey) ?a=1&a=2
    /// (commaseparated) ?a=1,2
    public var queryArrayEncodingStrategy: QueryArrayEncodingStrategy = .commaSeparated

    public init(_ url: String) {
        let comps = url.urlcomponents
        self.baseUrl = comps.baseUrl
        /// allows shorthand a la `somesite.com` to become `https://somesite.com`
        if url != comps.path {
            self._path = comps.path
        }
        self._query = comps._query
    }
    
    /// the other initializer attempts to handle most
    /// cases gracefully of decoding a user's url
    /// (adding https, decoding query, etc)
    ///
    /// if that is causing issues, this is provided
    /// as an override, it ignores all potential inference
    ///
    /// WARNING: adding paths to a base url with a query
    /// will append them after,
    /// ie: foble.com?k=v&abc=123/some/path
    /// this is an override function, if you're using it
    /// the framework is failing in some way to assemble the url
    /// please pass the url exactly including any queries
    /// or other url items
    public init(absoluteBaseUrl: String) {
        self.baseUrl = absoluteBaseUrl
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
            Log.warn("servers, or proxies in front of servers will sometimes ignore body on GET request")
        }
        
        if _method != .get, let body = _body {
            let body = try body.encode()
            request.setBody(json: body)
        }
        return request
    }

    /// based on the current state of the request,
    /// returns the url destination
    public var expandedUrl: String {
        let url: String
        if _path.isEmpty {
            url = baseUrl
        } else if _path.hasPrefix("/") {
            url = baseUrl.withTrailingSlash + _path.dropFirst()
        } else {
            url = baseUrl.withTrailingSlash + _path
        }
        
        if _method != .get, _query != nil {
            Log.warn("non-get requests may not support query params")
        }
        guard let query = _query else { return url }
        return url + "?" + makeQueryString(parameters: query)
    }

    // MARK: Query

    public enum QueryArrayEncodingStrategy {
        case commaSeparated, multiKeyed
    }

    private func makeQueryString(parameters: JSON) -> String {
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
    internal func makeResponderChain() -> NetworkCompletion {
        self.middlewares.reversed().reduce(onComplete) { (result, next) in
            return { res in
                next.handle(res, next: result)
            }
        } as NetworkCompletion
    }
    
}

// MARK: ObjBuilder

///
///so you can do:
///
///     Root()
///        .get("foo")
///        .q.key(value)
///        .q(key: value)
///        .q.ifTypedFillHereOrAlwaysDynamic
///
@dynamicMemberLookup
@dynamicCallable
public class ObjBuilder<Wrapped: BasicRequest> {
    public let base: Wrapped
    /// this has nothing to do with object keys
    /// it is a back reference to base so that
    /// the object can properly be set to body,
    /// or query, or other..
    public let kp: ReferenceWritableKeyPath<Root, JSON?>
    
    fileprivate init(_ backing: Wrapped, kp: ReferenceWritableKeyPath<Root, JSON?>) {
        self.base = backing
        self.kp = kp
    }
    
    public subscript(dynamicMember key: String) -> (CustomStringConvertible) -> Wrapped {
        return { value in
            self.dynamicallyCall(withKeywordArguments: .init(dictionaryLiteral: (key, value)))
        }
    }
    
    public subscript(dynamicMember key: String) -> (CustomStringConvertible) -> ObjBuilder {
        let kp = self.kp
        return { value in
            let next = self.dynamicallyCall(withKeywordArguments: .init(dictionaryLiteral: (key, value)))
            return ObjBuilder(next, kp: kp)
        }
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
        if let existing = base.wrapped[keyPath: kp] {
            base.wrapped[keyPath: kp] = existing.merged(with: body)
        } else {
            base.wrapped[keyPath: kp] = body
        }
        return base
    }

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) -> Wrapped {
        let body = JSON(args)
        if let existing = base.wrapped[keyPath: kp] {
            base.wrapped[keyPath: kp] = existing.merged(with: body)
        } else {
            base.wrapped[keyPath: kp] = body
        }
        return base
    }
}

extension JSON {
    /// attempts to reconcile multiple fragments into a single object
    /// argument has priority and will overwrite existing keys
    func merged(with js: JSON) -> JSON? {
        switch (self, js) {
        case (.object(var l), .object(let r)):
            r.forEach { k, v in
                l[k] = v
            }
            return .object(l)
        case (.array(let l), .array(let r)):
            return .array(l + r)
        case (.string(let l), .string(let r)):
            return .string(l + r)
        default:
            Log.warn("unable to merge json object")
            return nil
        }
    }
}

// MARK: Path Builder

/// used to build paths from an api root
@dynamicCallable
@dynamicMemberLookup
public class PathBuilder<Builder: BasicRequest> {
    public var get: HTTPMethod = .get
    public var post: HTTPMethod = .post
    public var put: HTTPMethod = .put
    public var patch: HTTPMethod = .patch
    public var delete: HTTPMethod = .delete

    public let base: Builder

    fileprivate init(_ base: Builder) {
        self.base = base
    }
    
    public func dynamicallyCall(withArguments args: [CustomStringConvertible]) -> Builder {
        guard !args.isEmpty else { return base }
        
        let components = args.map(\.description)
        let enforceTrailingSlash = components.last == "/"
        let addition = components.dropLast(enforceTrailingSlash ? 1 : 0)
            .joined(separator: "/")
        
        let component: String
        if addition == "/" {
            component = ""
        } else if enforceTrailingSlash {
            component = addition.withTrailingSlash
        } else {
            component = addition
        }
        
        base.wrapped._path = base.wrapped._path.withTrailingSlash + component
        return base
    }
    
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) -> Builder {
        var updated = base.wrapped._path

        if let arg = args.first, arg.key.isEmpty || arg.key == "path" {
            let arg = args[0]
            updated += "\(arg.value)"
        }

        args.forEach { key, replacement in
            guard !key.isEmpty && key != "path" else { return }
            let wrapped = "{\(key)}"
            let replacement = "\(replacement)"
            updated.replaceFirstOccurence(of: wrapped, with: replacement)
        }

        base.wrapped._path = updated
        return base
    }

    /// sometimes we do like `.get("path")`, sometimes we just do like `get.on(success:)`
    public subscript<T>(dynamicMember key: KeyPath<BasicRequest, T>) -> T {
        base[keyPath: key]
    }
}

// MARK: Handler Builder

/// used to add to the responder chain
/// based on the various response possibilities
public struct OnBuilder<Wrapped: BasicRequest, D: Decodable> {
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
    
    public func success<Mapped: Decodable>(_ mapped: @escaping (Mapped) -> Void) -> Wrapped {
        base.middleware(BasicHandler(onSuccess: mapped))
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
    public let base: Root

    init(_ base: Root) {
        self.base = base
    }

    // is this needed?
    public var detyped: some BasicRequest { base }
    public var basic: some BasicRequest { base }
}

extension BasicRequest {
    public func typed<D: Decodable>(as: D.Type = D.self) -> TypedBuilder<D> {
        TypedBuilder(wrapped)
    }
}

extension BasicRequest {
    /// for use with a standard bearer token format
    ///
    ///     Authorization: Bearer \(token)
    ///
    public func bearer(token: String) -> Self {
        self.h.authorization("Bearer \(token)")
    }
}

extension BasicRequest {
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
        (scheme ?? "https") + "://" + (host ?? path)
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
