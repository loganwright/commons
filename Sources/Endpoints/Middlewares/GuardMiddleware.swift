extension Base {
    // TODO: expand conditionals?
    public func `if`(_ condition: Bool, _ op: (Base) -> Base) -> Base {
        if condition {
            return op(self)
        } else {
            return self
        }
    }
}

