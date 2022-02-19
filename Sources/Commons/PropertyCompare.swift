/// this is a kind of weird class
/// but has some use on large, particularly outdated (non swift)
/// code bases where equatability isn't easily conformed
/// or when it is, it's based on a handful of properties
///
///     return lhs.abber == rhs.abber
///         && lhs.foo == rhs.foo
///         && lhs.blarble == lhs.blarble
///         && lhs.doopiedo == lhs.doopiedo
///
/// this isn't particularly problematic, but I did make a bug
/// (`lhs.blarble == lhs.blarble`)
/// this is a relatively easy mistake in large compare lists.
///
///     return PropertyCompare(lhs, rhs)
///         .equals(\.abber)
///         .equals(\.foo)
///         .equals(\.blarble)
///         .equals(\.doopiedo)
///         .result
///
/// easy to read, and no more bugs
///
public final class PropertyCompare<T> {
    public let a: T
    public let b: T
    
    public var result: Bool {
        records.map(\.pass).reduce(true) { current, next in
            current && next
        }
    }
    public private(set) var records: [(kp: PartialKeyPath<T>, pass: Bool)] = []
    
    public init(_ a: T, _ b: T) {
        self.a = a
        self.b = b
    }

    @discardableResult
    public func equals<U: Equatable>(_ kp: KeyPath<T, U>) -> Self {
        let _a = a[keyPath: kp]
        let _b = b[keyPath: kp]
        let pass = _a == _b
        records.append((kp, pass))
        return self
    }

    @discardableResult
    public func notEquals<U: Equatable>(_ kp: KeyPath<T, U>) -> Self {
        compare(kp, compare: !=)
    }
    
    private func compare<U: Equatable>(_ kp: KeyPath<T, U>, compare: (U, U) -> Bool) -> Self {
        let _a = a[keyPath: kp]
        let _b = b[keyPath: kp]
        let pass = compare(_a, _b)
        self.records.append((kp, pass))
        return self
    }
}
