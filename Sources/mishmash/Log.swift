struct Log {
    static func info(file: String = #file, line: Int = #line, _ msg: String) {
        let file = file.components(separatedBy: "/").last ?? "<>"
        print("\(file):\(line) - \(msg)")
    }
    static func warn(file: String = #file, line: Int = #line, _ msg: String) {
        let file = file.components(separatedBy: "/").last ?? "<>"
        print("*** WARNING ***")
        print("\(file):\(line) - \(msg)")
    }
    static func error(file: String = #file, line: Int = #line, _ err: Error) {
        let file = file.components(separatedBy: "/").last ?? "<>"
        print("!!*** ERROR ***!!")
        print("*****************")
        print("\(file):\(line) - \(err.localizedDescription)")
    }

    // MARK: Logs


    /// storing logs for easier testng
    static var _testable_logs: [String] = []
    #if DEBUG
    private static func print(_ str: String) {
        _testable_logs.append(str)
        Swift.print(str)
    }
    #endif
}