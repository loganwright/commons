import Foundation

//public let IS_TESTING = NSClassFromString("XCTest") != nil
public let IS_TESTING: Bool = {
    #if os(iOS)
    NSClassFromString("XCTest") != nil
    #else
    Log.critical("fix")
    #warning("need to think about best way to deal w this, crashing previews")
    return false
    #endif
}()

public let IS_SIMULATOR: Bool = {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
}()

public let IS_PRODUCTION: Bool = {
    #if DEBUG
    return false
    #else
    return true
    #endif
}()

public let NoNetworkErrorCode = NSURLErrorNotConnectedToInternet

public prefix func ! <T>(original: @escaping (T) -> Bool) -> (T) -> Bool {
    return { input in !original(input) }
}
