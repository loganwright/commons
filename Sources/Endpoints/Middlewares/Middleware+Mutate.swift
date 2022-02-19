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
            resp.replaceBody(with: new ?? .null)
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

// MARK: Chain

/// I don't know how to name this.
///
/// basically, it converts a result into a subsequent
/// request that requires that response
///
/// useful for combining for example multiple api calls into one
public struct ChainDependency<D: Decodable>: Middleware {
    private let map: (D) -> Base
    
    public init(_ map: @escaping (D) -> Base) {
        self.map = map
    }
    
    public func handle(_ result: Result<NetworkResponse, Error>, next: @escaping (Result<NetworkResponse, Error>) -> Void) {
        do {
            let resp = try result.unwrap(as: D.self)
            // still needs background?
//            background {
                map(resp)
                    .on.either(next)
                    .send()
//            }
        } catch {
            next(.failure(error))
        }
    }
}
