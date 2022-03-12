extension Root {
    // TODO: expand conditionals?
    public func `if`(_ condition: Bool, _ op: (Self) -> Self) -> Self {
        if condition {
            return op(self)
        } else {
            return self
        }
    }
}

extension Root {
    public func `guard`(_ condition: @escaping @autoclosure () -> Bool, else error: Error) -> Self {
        self.middleware(Guard(condition(), error: error))
    }
}

struct Guard: Middleware {
    let shouldPass: () -> Bool
    let error: Error
    init(_ shouldPass: @escaping @autoclosure () -> Bool, error: Error) {
        self.shouldPass = shouldPass
        self.error = error
    }

    func handle(_ result: Result<NetworkResponse, Error>, next: @escaping (Result<NetworkResponse, Error>) -> Void) {
        if shouldPass() {
            next(result)
        } else {
            next(.failure(error))
        }
    }
}
