import Foundation

extension Array {
    public var lastIdx: Int {
        return count - 1
    }
}

extension Array {
    public func collectFirst(_ amount: Int) -> Array {
        assert(0...count ~= amount)
        var collected = Array()
        while collected.count < amount {
            collected.append(self[collected.count])
        }
        return collected
    }
}

extension Array {
    public subscript(safe idx: Int) -> Element? {
        guard 0 <= idx, idx < count else { return nil }
        return self[idx]
    }
}



extension Array where Element: EncapsulationProtocol {
    public func flatten() -> [Element.Wrapped] {
        compactMap { $0.wrapped }
    }
}

extension Array {
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
