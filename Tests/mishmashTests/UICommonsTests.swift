import Foundation
import XCTest

//import UIKit
@testable import Commons
@testable import Endpoints
@testable import UICommons

class UICommonsTests: XCTestCase {
    func testRectInterpolation() {
        let rect = CGRect(x: 32, y: 11, width: 399, height: 891)
        let interpolated = "\(rect)"
        XCTAssertEqual(interpolated, "x.32.0, y.11.0, w.399.0, h.891.0")
    }
}
