extension JSON: PathIndexable {
    public var pathIndexableArray: [JSON]? {
        array
    }
    
    public var pathIndexableObject: [String : JSON]? {
        object
    }
    
    public init(_ array: [JSON]) {
        self = .array(array)
    }
    
    public init(_ object: [String : JSON]) {
        self = .object(object)
    }
}
