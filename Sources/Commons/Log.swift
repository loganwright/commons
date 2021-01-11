public struct Log {
    public static func info(file: String = #file, line: Int = #line, _ msg: String) {
        let file = file.components(separatedBy: "/").last ?? "<>"
        print("\(file):\(line) - \(msg)")
    }
    public static func warn(file: String = #file, line: Int = #line, _ msg: String) {
        let file = file.components(separatedBy: "/").last ?? "<>"
        print("*** WARNING ***")
        print("\(file):\(line) - \(msg)")
    }
    public static func error(file: String = #file, line: Int = #line, _ err: Error) {
        let file = file.components(separatedBy: "/").last ?? "<>"
        print("!!*** ERROR ***!!")
        print("*****************")
        print("\(file):\(line) - \(err.display)")
    }

    // MARK: Logs


    public static var unsafe_collectDebugLogs = false
    public static var unsafe_debugLogMaxEntries = 500

    private static var _unsafe_testable_logs: [String] = []

    private static func add(log: String) {
        defer { _unsafe_testable_logs.append(log) }
        guard _unsafe_testable_logs.count >= unsafe_debugLogMaxEntries else { return }
        do {
            /// overwrite last entries
            try Files.debugLogs.write(filename: ".logs", _unsafe_testable_logs)
            _unsafe_testable_logs = []
        } catch {
            Log.warn("unable to write logs")
            _unsafe_testable_logs.removeFirst()
        }
    }

    public static func fetchLogs() -> [String] {
        do {
            let logs = try Files.debugLogs.read(filename: ".logs", as: [String].self) ?? []
            return logs + _unsafe_testable_logs
        } catch {
            Log.warn("unable to read logs")
            return _unsafe_testable_logs
        }
    }

    private static func print(_ str: String) {
        #if DEBUG
        Swift.print(str)
        #endif

        if unsafe_collectDebugLogs { add(log: str) }
    }
}

extension Files {
    public static let debugLogs = Files(folder: "logs", encrypted: true)
}


import Foundation

extension Error {
    public var display: String {
        let ns = self as NSError
        let _localized = ns.userInfo[NSLocalizedDescriptionKey]
        if let nested = _localized as? NSError {
            return nested.display
        } else if let string = _localized as? String {
            let raw = Data(string.utf8)
            if let json = try? JSON.decode(raw) {
                return json.nonFieldErrors?.string ?? json.message?.string ?? "\(json)"
            } else {
                return ns.domain + ":\n" + "\(ns.code) - " + string
            }
        } else {
            return "\(self)"
        }
    }
}


public func warnIfNil<T>(file: String = #file, line: Int = #line, _ thing: T?, _ msg: String) {
    if let _ = thing { return }
    else {
        Log.warn(file: file, line: line, "unexpectedly found nil: \(msg)")
    }
}
