import Commons

// MARK: ModifyBody

/// used to modify the entire body of
/// a response
public struct ModifyBody: Middleware {
    public let modifier: (JSON?) throws -> JSON?
    
    public init(_ modifier: @escaping (JSON?) throws -> JSON?) {
        self.modifier = modifier
    }
    
    public func handle(_ result: Result<NetworkResponse, Error>, next: @escaping (Result<NetworkResponse, Error>) -> Void) {
        do {
            var resp = try result.get()
            let new = try modifier(resp.json)
            resp.json = new
            next(.success(resp))
        } catch {
            next(result)
        }
    }
}

// MARK: Extract KeyPath

extension ModifyBody {
    /// in a given response, body, instead pass along
    /// value at given kp
    ///
    ///     {
    ///       "extra": 1,
    ///       "info": "I don't need this stuff",
    ///       "items": [
    ///         // imagine lots here
    ///       ]
    ///     }
    ///
    /// with this, you can access the list at `\.items`
    /// and proceed as if api had returned a list
    ///
    ///     .middleware(ModifyBody(extract: \.items), to: .front)
    ///
    /// NOTE: make sure it's at the front of your middleware
    /// or at least before subsequent handlers expect result
    public init(extracting kp: KeyPath<JSON, JSON?>) {
        modifier = { input in
            input?[keyPath: kp]
        }
    }
}

extension BaseWrapper {
    
    /// when the desired data is nested inside of a bigger response
    /// this can be used to extract it
    /// ie:
    ///
    ///     {
    ///         "children": [
    ///         ...
    ///
    /// would access like:
    ///
    ///     Host.myapi
    ///         .extracting(dataPath: \.children)
    ///         .on.success { children in
    ///             // extract children here
    ///
    /// - Parameters:
    ///   - kp: the path pointing to the data
    ///   - front: whether or not the extraction should go to the front of the responder chain
    public func extracting(dataPath kp: KeyPath<JSON, JSON?>, front: Bool = true) -> Self {
        middleware(ModifyBody(extracting: kp), front: front)
    }
}

// MARK: Chain

/// I don't know how to name this.
///
/// basically, it converts a result into a subsequent
/// request that requires that response
///
/// useful for combining for example multiple api calls into one
public struct ChainDependency<D: Decodable>: Middleware {
    private let map: (D) -> BaseWrapper
    
    public init(_ map: @escaping (D) -> BaseWrapper) {
        self.map = map
    }
    
    public func handle(_ result: Result<NetworkResponse, Error>, next: @escaping (Result<NetworkResponse, Error>) -> Void) {
        do {
            let resp = try result.unwrap(as: D.self)
            map(resp)
                .on.result(next)
                .send()
        } catch {
            next(.failure(error))
        }
    }
}

extension BaseWrapper {
    /// chain subsequent requests that are dependent on the body of
    /// a preceding request
    public func chain<D: Decodable>(responseTo map: @escaping (D) -> BaseWrapper) -> Self {
        middleware(ChainDependency(map))
    }
    
    /// chain subsequent requests that are dependent on the body of
    /// a preceding request
    public func chain(responseTo map: @escaping (JSON?) -> BaseWrapper) -> Self {
        middleware(ChainDependency(map))
    }
}
