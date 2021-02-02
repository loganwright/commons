/// concats blocks together so they aggregate and run sequentially
@propertyWrapper
public final class ResponderChain {
    private var chain: [() -> Void] = []
    public var wrappedValue: () -> Void {
        get {
            return chain.reduce({}) { previous, next in
                return {
                    previous()
                    next()
                }
            }
        }
        set {
            chain.append(newValue)
        }
    }

    public init(wrappedValue: @escaping () -> Void) {
        self.wrappedValue = wrappedValue
    }
}

/// same as ResponderChain but w arguments
@propertyWrapper
public final class TypedResponderChain<T> {
    public var wrappedValue: (T) -> Void {
        didSet {
            let newValue = wrappedValue
            wrappedValue = {
                oldValue($0)
                newValue($0)
            }
        }
    }

    public init(wrappedValue: @escaping (T) -> Void) {
        self.wrappedValue = wrappedValue
    }
}

extension TypedResponderChain where T == Int {
    convenience init(wrappedValue: @escaping () -> Void) {
        self.init { _ in
            wrappedValue()
        }
    }
}
