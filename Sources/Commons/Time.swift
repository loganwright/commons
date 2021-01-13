import Foundation

public struct Time: Codable, Equatable {
    public enum Style {
        case amPM
        case twentyFourHour
    }

    public let hours: Int
    public let minutes: Int

    public init(_ str: String) {
        let comps = str.components(separatedBy: "::").compactMap(Int.init)
        assert(comps.count == 2)
        self.init(hours: comps[0], minutes: comps[1])
    }

    public init(hours: Int, minutes: Int) {
        assert(0...23 ~= hours)
        assert(0...59 ~= minutes)

        self.hours = hours
        self.minutes = minutes
    }

    public func display(in style: Style) -> String {
        var hrs = hours.description
        if hours < 12 { hrs = "0" + hrs }
        var mins = minutes.description
        if minutes < 10 { mins = "0" + mins}
        if style == .twentyFourHour { return "\(hrs):\(mins)" }

        var adjustedHour = hours
        if hours > 12 { adjustedHour -= 12 }
        else if hours == 0 { adjustedHour = 12 }

        let amPM = hours < 12 ? "AM" : "PM"
        return "\(adjustedHour):\(mins) \(amPM)"
    }
}

extension Date {
    public var time: Time {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return .init(hours: comps.hour!, minutes: comps.minute!)
    }
}

