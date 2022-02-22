import Foundation

extension Double {
    @available(*, deprecated: 1.0, message: "use .limitPlaces(to:)")
    public var twoDecimalPlaces: String {
        String(format: "%.2f", self)
    }
    public func limitPlaces(to: Int = 2) -> String {
        String(format: "%.\(to)f", self)
    }
}

extension Int {
    /// used for padding `0` to display numbers
    ///
    /// - Parameter spaces: number of spaces, ie: spaces: 2 on an Int(1) will display '01'
    /// - Returns: zero padded display string
    public func display(spaces: Int) -> String {
        guard spaces > 1 else { return description }
        let str = self.description
        guard str.count < spaces else { return str }
        let padding = String(repeating: "0", count: (spaces - str.count))
        if self >= 0 {
            return padding + str
        } else {
            return "-" + abs(self).display(spaces: spaces)
        }
    }
}

extension Double {
    var displayPercent: String {
        Int(self * 100).description + "%"
    }
}
