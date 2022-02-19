import Commons

// Middlewarewolves

public protocol Middleware {
    func handle(_ result: Result<NetworkResponse, Error>,
                next: @escaping (Result<NetworkResponse, Error>) -> Void)
}

// MARK: BasicHandler

/// This middleware is great for detached operations
/// that don't modify the result to pass downstream
public struct BasicHandler: Middleware {
    public let handler: (Result<NetworkResponse, Error>) throws -> Void

    public init(basic: @escaping (Result<NetworkResponse, Error>) throws -> Void) {
        self.handler = basic
    }

    public func handle(_ result: Result<NetworkResponse, Error>,
                next: @escaping (Result<NetworkResponse, Error>) -> Void) {
        do {
            try handler(result)
            next(result)
        } catch {
            Log.error(error)
            next(.failure(error))
        }
    }
}

extension BasicHandler {
    public init(onSuccess: @escaping  () -> Void) {
        self.init(basic: { result in
            guard case .success = result else { return }
            onSuccess()
        })
    }
}

extension BasicHandler {
    public init(onError: @escaping  (Error) -> Void) {
        self.init(basic: { result in
            guard case .failure(let err) = result else { return }
            onError(err)
        })
    }
}

extension BasicHandler {
    public init(onSuccess: @escaping (NetworkResponse) -> Void) {
        self.init(basic: { result in
            guard let value = result.value else { return }
            onSuccess(value)
        })
    }

    public init<D: Decodable>(onSuccess: @escaping (D) -> Void) {
        self.init(basic: { result in
            guard let value = result.value else { return }
            print("handling: \(D.self)")
            let decoded = try D.decode(value)
            onSuccess(decoded)
        })
    }
}
