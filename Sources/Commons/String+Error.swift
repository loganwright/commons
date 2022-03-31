import Foundation

/// this may be lazy, but it's my favorite thing, and
/// makes errors way easier to at least make notes
/// about during dev
extension String: Error {}

extension String {
    /// was running into strange conversion
    /// errors, omit if possible, but test thoroughly
    public var nserr: NSError {
        return (self as Error) as NSError
    }
}

// MARK: Display

extension Error {
    /// attempts to render an error into
    /// something that is readable
    public var display: String {
        let ns = self as NSError
        let _localized = ns.userInfo[NSLocalizedDescriptionKey]
        if let nested = _localized as? NSError {
            return nested.display
        } else if let string = _localized as? String {
            let raw = Data(string.utf8)
            if let json = try? JSON.decode(raw) {
                return json.nonFieldErrors?.string
                    ?? json.message?.string
                    ?? json.detail?.string
                    ?? "\(json)"
            } else {
                return ns.domain + ":\n" + "\(ns.code) - " + string
            }
        } else {
            let str = "\(self)"
            return str.toJSONErrorDisplay ?? str
        }
    }
}

extension String {
    fileprivate var toJSONErrorDisplay: String? {
        ( try? JSON.decode(Data(utf8)) ) .flatMap { json in
            return json.nonFieldErrors?.string
                ?? json.message?.string
                ?? json.detail?.string
                ?? "\(json)"
        }
    }
}
