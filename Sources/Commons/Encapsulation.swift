/// allows mostly for some special considerations around
/// optionals and generics
public protocol EncapsulationProtocol {
    associatedtype Wrapped
    var wrapped: Wrapped? { get }
}

extension Optional: EncapsulationProtocol {
    public var wrapped: Wrapped? { self }
}
