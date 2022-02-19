extension JSON: PathIndexable {
    public var pathIndexableArray: [JSON]? {
        array
    }
    
    public var pathIndexableObject: [String : JSON]? {
        obj
    }
    
    public init(_ array: [JSON]) {
        self = .array(array)
    }
    
    public init(_ object: [String : JSON]) {
        self = .obj(object)
    }
}
