import Foundation

public final class HeadersBuilderExistingKey<Wrapper: BasicRequest> {
    public let key: String
    private let base: Wrapper

    internal init(_ base: Wrapper, key: String) {
        self.base = base
        self.key = key
    }
    
    public func callAsFunction(_ val: CustomStringConvertible) -> Wrapper {
        base.wrapped._headers[key] = val.description
        return base
    }
}

@dynamicMemberLookup
public final class HeadersBuilder<Wrapper: BasicRequest> {
    public let base: Wrapper

    internal init(_ base: Wrapper) {
        self.base = base
    }

    public func callAsFunction(_ key: String, _ val: CustomStringConvertible) -> Wrapper {
        base.wrapped._headers[key] = val.description
        return base
    }

    public subscript(dynamicMember key: KeyPath<HeaderKey, HeaderKey>) -> HeadersBuilderExistingKey<Wrapper> {
        let headerKey = HeaderKey(stringLiteral: "")[keyPath: key]
        return .init(base, key: headerKey.stringValue)
    }
    
    public subscript(dynamicMember key: String) -> HeadersBuilderExistingKey<Wrapper> {
        return .init(base, key: key.toHeaderKey)
    }
}

extension CharacterSet {
    static let uppercaseLetters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
}

extension Unicode.Scalar {
    var isUppercase: Bool {
        CharacterSet.uppercaseLetters.contains(self)
    }
}

extension String {
    var camelcaseComponents: [String] {
        self.splitIncludeDelimiter(whereSeparator: \.isUppercase).map { String($0) }
    }
    
    fileprivate var toHeaderKey: String {
        var comps = self.camelcaseComponents
        comps[0] = comps[0].capitalized
        return comps.joined(separator: "-")
    }
}

extension Sequence {
    func splitIncludeDelimiter(whereSeparator shouldDelimit: (Element) throws -> Bool) rethrows -> [[Element]] {
        try self.reduce([[]]) { group, next in
            var group = group
            if try shouldDelimit(next) {
                group.append([next])
            } else {
                group[group.lastIdx].append(next)
            }
            return group
        }
    }
}
