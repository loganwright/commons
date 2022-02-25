#if canImport(Combine)
import XCTest

import Combine
@testable import Commons
@testable import Endpoints

final class AlwaysTests: XCTestCase {
    func testItEmitsASingleValue() {
    }

    var cancellables = [AnyCancellable]()
    var published: JSON = [:] {
        didSet {
            XCTAssertEqual(published.id, "asfdlkjdsf")
            XCTAssertEqual(published.name, "flia")
            XCTAssertEqual(published.age, 234)
        }
    }

    func testBasePublisher() {
        Base("https://httpbin.org")
            .post.path("post") // weird httpbin naming
//            .post(path: "post")
            .contentType("application/json")
            .accept("application/json")
            .header("Custom", "more")
            .body(id: "asfdlkjdsf", name: "flia", age: 234)
            .publisher
            .compactMap { $0.json?["json"] }
            .catch { _ in
                Just([:])
            }
            .assign(to: \.published, on: self)
            .store(in: &cancellables)
    }
}

#endif
