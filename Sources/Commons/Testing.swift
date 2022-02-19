#if canImport(XCTest)

import XCTest

extension XCTestCase {
    public func fail(_ error: Error) {
        XCTFail("error: \(error)")
    }

    public func execute(name: String, _ op: (XCTestExpectation) -> Void) {
        Log.trace("testing: \(name)")
        let expectation = XCTestExpectation(description: name)
        op(expectation)
        wait(for: [expectation], timeout: 20.0)
    }
}

#endif
