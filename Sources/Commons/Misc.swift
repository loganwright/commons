public func catching<U>(
    fileID: String = #fileID,
    line: Int = #line,
    function: String = #function,
    _ throwable: () throws -> U?,
    fallback: () -> U? = { nil }
) -> U? {
    do {
        return try throwable()
    } catch {
        Log.error(fileID: fileID, line: line, function: function, error)
        return fallback()
    }
}
