import Foundation

// MARK: Log

/// entry point for logging, use via the cases
///
///     Log.trace("contentView::didAppear")
///     Log.error("big error oh no")
///
public enum Log: Int, CaseIterable, Codable, Equatable, Hashable {
    
    /// outputs to push logs through
    public static var outputs: [LogOutput] = .defaults
    
    /// available log levels
    ///
    /// mirror swift logs for future integration
    case trace,
         debug,
         info,
         notice,
         warn,
         error,
         critical

    /// a visual symbol to easily identify
    public var symbol: Character {
        switch self {
        case .trace:
            return "-"
        case .debug:
            return "◦"
        case .info:
            return "•"
        case .notice:
            return "*"
        case .warn:
            return "!"
        case .error:
            return "∆"
        case .critical:
            return "※"
        }
    }
    
    /// make log
    public func callAsFunction(fileID: String = #fileID, line: Int = #line, function: String = #function, _ msg: String) {
        let crumb = LogMeta(fileID: fileID, line: line, function: function, level: self)
        output(crumb, msg: msg)
    }
    
    /// make log
    public func callAsFunction<T>(fileID: String = #fileID, line: Int = #line, function: String = #function, _ msg: T?) {
        let crumb = LogMeta(fileID: fileID, line: line, function: function, level: self)
        let msg = msg.flatMap({ "\($0)" }) ?? "<nil>"
        output(crumb, msg: msg)
    }
    
    private func output(_ crumb: LogMeta, msg: String) {
        let entry = Entry(crumb: crumb, msg: msg)
        Log.outputs.log(entry)
    }
}

// MARK: Log+Extras

extension Array where Element == Log {
    public static var allCases: [Log] {
        Log.allCases
    }
    public static func greaterThan(_ base: Log) -> [Log] {
        allCases.filter { $0 > base }
    }
    public static func greaterOrEqualTo(_ base: Log) -> [Log] {
        allCases.filter { $0 >= base }
    }
    public static func lessThan(_ base: Log) -> [Log] {
        allCases.filter { $0 < base }
    }
    public static func lessOrEqualTo(_ base: Log) -> [Log] {
        allCases.filter { $0 <= base }
    }
}

extension Log: Comparable {}
public func < (lhs: Log, rhs: Log) -> Bool {
    lhs.rawValue < rhs.rawValue
}

// MARK: Output

public protocol LogOutput {
    func log(_ entry: Entry)
}

@dynamicMemberLookup
public struct Entry: Codable {
    let crumb: LogMeta
    let msg: String
    
    var display: String { crumb.tag + msg }
    
    subscript<T>(dynamicMember kp: KeyPath<LogMeta, T>) -> T {
        crumb[keyPath: kp]
    }
}

extension Array where Element == LogOutput {
    public static var `defaults`: [LogOutput] {
        #if DEBUG
        return [
            MemoryLogs(.allCases),
            StandardLog(.allCases),
        ]
        #else
        return [
            // RemoteLogs(.greaterOrEqualTo(.notice))
        ]
        #endif
    }
}

public struct StandardLog: LogOutput {
    public let levels: [Log]
    
    public init(_ levels: [Log]) {
        self.levels = levels
    }
    
    public func log(_ entry: Entry) {
        guard levels.contains(entry.level) else { return }
        Swift.print(entry.display)
    }
}

public class MemoryLogs: LogOutput {
    public let levels: [Log]
    public var max: Int
    
    // TODO: Organize by level
    public var logs: [Entry] = [] {
        didSet {
            let overflow = logs.count - max
            guard overflow > 0 else { return }
            logs.removeFirst(overflow)
        }
    }
    
    public init(_ levels: [Log], max: Int = 1024) {
        self.levels = levels
        self.max = max
    }
    
    public func log(_ entry: Entry) {
        guard levels.contains(entry.level) else { return }
        logs.append(entry)
    }
}

extension Array where Element == Entry {
    public subscript(level: Log) -> [Entry] {
        filter { $0.level == level }
    }
}

extension Array: LogOutput where Element == LogOutput {
    public var memory: MemoryLogs? {
        self.lazy.compactMap { $0 as? MemoryLogs } .first
    }
    
    public func log(_ entry: Entry) {
        forEach { output in
            output.log(entry)
        }
    }
}

// MARK: Meta

/// small objects that contain metadata
/// about where a given log came from
public struct LogMeta: Codable, Equatable {
    /// currently only this system supported
    private var compact: String {
        var formatted = "[\(level.symbol.description)]"
        formatted += " "
        formatted += created.timeStamp
        formatted += " "
        formatted += fileID.sourceFileName
        formatted += "."
        formatted += function.functionName
        formatted += "[\(line)]"
        formatted += " - "
        return formatted
    }
    
    public var tag: String { compact }
    
    public let fileID: String
    public let line: Int
    public let function: String
    public let level: Log
    public let created: Date
    
    public init(fileID: String = #fileID, line: Int = #line, function: String = #function, level: Log) {
        self.fileID = fileID
        self.line = line
        self.function = function
        self.level = level
        self.created = .init()
    }
}

// MARK: Formatting

extension Date {
    fileprivate var timeStamp: String {
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let h = comps.hour!.display(spaces: 2)
        let m = comps.minute!.display(spaces: 2)
        let s = comps.second!.display(spaces: 2)
        return h + ":" + m + ":" + s
    }
}


// MARK: Precondition Formatting

extension String {
    /// for use with #filePath or #fileID
    public var sourceFileName: String {
        components(separatedBy: "/").last?.components(separatedBy: ".").first ?? "<>"
    }
    
    /// for use with #function
    public var functionName: String {
        components(separatedBy: "(").first ?? "<>"
    }
}
