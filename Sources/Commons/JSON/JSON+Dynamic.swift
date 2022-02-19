extension JSON {
    /// access with any dynamic path, extendible
    /// dynamic properties associated with JSON
    /// are NOT typesafe
    public subscript(dynamicMember key: String) -> JSON? {
        get {
            return self[key]
        }
        set {
            self[key] = newValue
        }
    }

    /// codable objects can be added to any JSON directly
    /// they will be automatically converted
    ///
    /// this is slightly more performant than other
    /// conversions for basic types
    /// as it has a special override function
    ///
    /// if there is really weird behavior, check that area
    public subscript<C: Codable>(dynamicMember key: String) -> C? {
        get {
            catching {
                try self[key]?.convert()
            }
        }
        set {
            self[key] = catching {
                try newValue?.convert()
            }
        }
    }
    
    // Links
    
    /// the dynamicism of this type is what makes it good
    /// however, having `a?.long?.chain?.of?.question?.marks?`
    /// was becoming too much
    ///
    /// now do:
    ///
    ///     a.long.chain.no.question.marks?.string
    public subscript(dynamicMember key: String) -> LinkedPath {
        get {
            LinkedPath(self, segment: key)
        }
        set {
            self = newValue.json
        }
    }
    
    /// occassionally there is ambiguity between
    /// `LinkedPath` and `JSON`
    /// can use this like `?.js`
    /// or `as JSON`
    public var js: JSON {
        self
    }
}

/// this thing is perhaps a little anti-swift
/// but building on the convenience of json, particularly
/// in early dev and tests
/// this allows `.` access dynamically
/// without excessive `?`
///
///     response.items.someId._0
@dynamicMemberLookup
public struct LinkedPath {
    public var json: JSON
    public let root: Link

    @Box
    public var children: [Link] = []

    fileprivate init(_ json: JSON, segment: String) {
        self.json = json
        self.root = Link(segment)
    }
    
    /// duplicate, see - JSON
    public subscript(dynamicMember key: String) -> JSON? {
        get {
            json[path + [key]]
        }
        set {
            json[path + [key]] = newValue
        }
    }
    
    /// duplicate, see - JSON
    public subscript<C: Codable>(dynamicMember key: String) -> C? {
        get {
            catching {
                try self[dynamicMember: key]?.convert()
            }
        }
        set {
            self[dynamicMember: key] = catching {
                try newValue?.convert()
            }
        }
    }
    
    // links
    
    public subscript(dynamicMember key: String) -> LinkedPath {
        get {
            children.append(Link(key))
            return self
        }
        set {
            self = newValue
        }
    }
    
    /// assembles the path to current link
    private var path: [String] {
        [root.segment] + children.map(\.segment)
    }
}

extension LinkedPath {
    /// need distinct value types to
    /// properly push changes back up
    /// the property tree
    public struct Link {
        public let segment: String
        public init(_ segment: String) {
            self.segment = segment
        }
    }
}
