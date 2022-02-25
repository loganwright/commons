import Foundation

extension Array {
    /// the last accessible index
    public var lastIdx: Int {
        return count - 1
    }
}

extension Array {
    /// returns `nil` if empty or out of range
    public subscript(safe idx: Int) -> Element? {
        guard 0 <= idx, idx < count else { return nil }
        return self[idx]
    }
}


extension Array {
    /// modulo indexed, always produces an element
    /// if there is at least one
    ///
    ///     let list = ["a", "b", "c"]
    ///     list[0] // a
    ///     list[1] // b
    ///     list[2] // c
    ///     list[3] // a
    ///     list[4] // b
    ///
    public subscript(revolving idx: Int) -> Element {
        self[idx % count]
    }
}

extension Sequence where Element: EncapsulationProtocol {
    public func flatten() -> [Element.Wrapped] {
        compactMap { $0.wrapped }
    }
}

extension Sequence {
    public func flatten<T>(as t: T.Type) -> [T] {
        compactMap { $0 as? T }
    }
}

extension Sequence {
    public var array: [Element] { Array(self) }
}

extension Sequence where Element: Hashable {
    public var set: Set<Element> { Set(self)}
}

// MARK: Flushing

extension Array {
    public mutating func flush<T>(whereNil kp: KeyPath<Element, T?>) {
        self = self.filter { $0[keyPath: kp] != nil }
    }

    public mutating func flush(where shouldFlush: (Element) -> Bool) {
        self = self.filter { !shouldFlush($0) }
    }
}

extension Array {
    public mutating func flush<T: Equatable>(where kp: KeyPath<Element, T?>, matches: T?) {
        self = self.filter { $0[keyPath: kp] == matches }
    }

    public mutating func flush<T: AnyObject>(where kp: KeyPath<Element, T?>, matches: T?) {
        self = self.filter { $0[keyPath: kp] === matches }
    }
}

// MARK: KeyPath

extension RangeReplaceableCollection {
    // first
    @inlinable public func first<T: Equatable>(where kp: KeyPath<Element, T>, matches: T) -> Element? {
        first(where: { $0[keyPath: kp] == matches })
    }
    @inlinable public func firstIndex<T: Equatable>(where kp: KeyPath<Element, T>, matches: T) -> Index? {
        firstIndex(where: { $0[keyPath: kp] == matches })
    }
    
    // filter
    @inlinable public func filter<T: Equatable>(where kp: KeyPath<Element, T>, matches: T) -> Self {
        filter({ $0[keyPath: kp] == matches })
    }
    @inlinable public func filter<T: Equatable>(where kp: KeyPath<Element, T>, not match: T) -> Self {
        filter({ $0[keyPath: kp] != match })
    }
}

extension Array where Element: Identifiable {
    @inlinable public func first(matchingId id: Element.ID) -> Element? {
        first(where: \.id, matches: id)
    }
    @inlinable public func firstIndex(matchingId id: Element.ID) -> Int? {
        firstIndex(where: \.id, matches: id)
    }
}


// MARK: ...

extension Array {
    public mutating func set<T>(each kp: WritableKeyPath<Element, T>, to new: T) {
        self = self.map { element in
            var element = element
            element[keyPath: kp] = new
            return element
        }
    }

    public func set<T>(each kp: ReferenceWritableKeyPath<Element, T>, to new: T) {
        self.forEach { element in
            element[keyPath: kp] = new
        }
    }

    public func pass<T>(each kp: KeyPath<Element, (T) -> Void>, arg: T) {
        self.forEach { element in
            // can I just map this?
            let function = element[keyPath: kp]
            function(arg)
        }
    }
}
