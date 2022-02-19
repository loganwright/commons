import Foundation

public struct Time: Codable, Equatable {
    public enum Style {
        case amPM
        case twentyFourHour
    }

    public let hours: Int
    public let minutes: Int

    public init(hours: Int, minutes: Int) {
        assert(0...23 ~= hours)
        assert(0...59 ~= minutes)

        self.hours = hours
        self.minutes = minutes
    }

    public func display(in style: Style) -> String {
        let hrs = hours.display(spaces: 2)
        let mins = minutes.display(spaces: 2)

        switch style {
        case .twentyFourHour:
            return "\(hrs):\(mins)"
        case .amPM:
            var adjustedHour = hours
            if hours > 12 { adjustedHour -= 12 }
            else if hours == 0 { adjustedHour = 12 }
            
            let amPM = hours < 12 ? "AM" : "PM"
            return "\(adjustedHour):\(mins) \(amPM)"
        }
    }
}

extension Date {
    public var time: Time {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return .init(hours: comps.hour!, minutes: comps.minute!)
    }
}

