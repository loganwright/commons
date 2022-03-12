import Foundation

/// ensures an email address is valid
@propertyWrapper
public struct Email {
    public private(set) var wrappedValue: String
    
    public init(_ str: String) throws {
        guard str.isValidEmail else {
            throw "\(str) is not a valid email address"
        }
        self.wrappedValue = str
    }
}

extension String {
    /// validates if a string would be a valid email
    /// (based on characters, email may not exist)
    public var isValidEmail: Bool {
        let emailRegEx: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred: NSPredicate = NSPredicate(format:"SELF MATCHES %@",
                                                 emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

// UICommons
