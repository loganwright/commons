/// encapsulate a reference type with a weak pointer
///
/// useful, for things like an array of
/// weakly referenced objects
@propertyWrapper
public struct Weak<T: AnyObject> {
    public weak var wrappedValue: T?
    public init(_ wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}
