import Foundation
import XCTest
@testable import Commons
@testable import Endpoints

extension Base {
    static var httpbin: Base { Base("https://httpbin.org") }
}

extension Endpoint {
    var testGet: Endpoint { "get" }
    var users: Endpoint { "users" }
}

class EndpointsTests: XCTestCase {
    func testNotes() {
        Log.warn("should change name? ambiguous w Foundation.Host")
    }
    
    func testUrlParts() {
        let raw = "https://api-test.padcaster-core.com/api/v0/files/commit/?args=%7B%22user%22%3A+1%2C+%22file%22%3A+114%2C+%22target%22%3A+5%2C+%22name%22%3A+%22BigBuckBunny.ogv+-+COPY+-+1%22%7D.1645788163.5bf321ca3e683807aee13904a536c614c7be1710b0f3362eba92d487d0d43bc5"
        let base = Base(raw)
        XCTAssertEqual(base.baseUrl, "https://api-test.padcaster-core.com")
        XCTAssertEqual(base._path, "/api/v0/files/commit/")
        XCTAssert(base._query?.args?.string?.isEmpty == false)
    }
    
    func testUrlId() {
        let base = Base("https://someurl.com/")
            .users
            .get as Base
        
        XCTAssertEqual(base.expandedUrl, "https://someurl.com/users")
        
        let ided = base.id("1235/")
        XCTAssertEqual(ided.expandedUrl, "https://someurl.com/users/1235/")
        
        
        let direct = Base("https://someurl.com/")
            .users(1235, "/") as Base
        XCTAssertEqual(direct.expandedUrl, "https://someurl.com/users/1235/")
        
        let multi = Base("https://someurl.com/")
            .get("users", 1235, "/") as Base
        XCTAssertEqual(multi.expandedUrl, "https://someurl.com/users/1235/")
    }

    func testOrdered() throws {
        let orderedTestCases = [
            ("testGet", testGet),
            ("testPost", testPost),
            ("testError", testError),
            ("testBasicAuth", testBasicAuth),
            ("testSerialize", testSerialize),
        ]

        orderedTestCases.forEach(execute)
    }

    func testGet(_ group: XCTestExpectation) {
        Base.httpbin
            .get
            .testGet
            // all identical
            .h("Content-Type", "application/json")
            .header("Content-Type", "application/json")
            .h.contentType("application/json")
            .header.contentType("application/json")
            .contentType("application/json")
            .header("X-App-Addition-Version", 1.02)
            .header("Accept", "application/json")
            .query(name: "flia", age: 234)
            .client(TrafficObserver.default)
            .on.success { json in
                XCTAssertEqual(json.args?.name?.string, "flia")
                XCTAssertEqual(json.args?.age?.int, 234)
            }
            .testing(on: group)
            .send()
    }

    func testPost(_ group: XCTestExpectation) {
        struct Person: Codable {
            let name: String
            let age: Int
        }
        Base.httpbin.post("post")
            .h.contentType("application/type")
            .h.accept("application/json")
            .body(name: "flia", age: 234)
            /// the data is nested
            .extracting(dataPath: \.json)
            .typed(as: Person.self)
            .on.success { flia in
                XCTAssertEqual(flia.name, "flia")
                XCTAssertEqual(flia.age, 234)
            }
            .on.error { err in
                Log.info("")
            }
            .testing(on: group)
            .send()
    }

    func testError(_ group: XCTestExpectation) {
        Base.httpbin
            .get("status", 345)
            .contentType("application/json")
            .accept("application/json")
            .on.success { result in
                XCTFail("should fail w error code")
            }
            .on.error { error in
                let ns = error as NSError
                XCTAssertEqual(ns.code, 345)
            }
            /// dont use `.testing(on:` will create errors
            .on.either(group.fulfill)
            .send()
    }

    func testBasicAuth(_ group: XCTestExpectation) {
        let user = "lorbo"
        let pass = "asdfjljv922"
        Base.httpbin
            .get("basic-auth/{user}/{pass}", user: user, pass: pass)
            .accept("application/json")
            .basicAuth(user: user, password: pass)
            .on.success { user in
                XCTAssertEqual(user.authenticated?.bool, true)
            }
            .testing(on: group)
            .send()
    }

    struct BasicUser: Codable {
        let id: String
        let name: String
        let age: Int
    }
    func testSerialize(_ group: XCTestExpectation) {
        Base("https://httpbin.org")
            .post(path: "post")
            .contentType("application/json")
            .accept("application/json")
            .header("Custom", "more")
            .body(id: "asfdlkjdsf", name: "flia", age: 234)
            .middleware(ModifyBody(extracting: \.json), front: true)
            .typed(as: BasicUser.self)
            .on.error { error in
                Log.error(error)
            }
            .on.success { user in
                XCTAssertEqual(user.id, "asfdlkjdsf")
                XCTAssertEqual(user.name, "flia")
                XCTAssertEqual(user.age, 234)
            }
            .testing(on: group)
            .send()
    }
}

// In basic HTTP authentication, a request contains a header field in the form of Authorization: Basic <credentials>, where credentials is the Base64 encoding of ID and password joined by a single colon :.

extension Base {
    func basicAuth(user: String, password: String) -> Base {
        let joined = user + ":" + password
        let encoded = Data(joined.utf8).base64EncodedString()
        return self.authorization("Basic \(encoded)")
    }
}

extension Endpoint {
    var testPost: Endpoint { "post" }
}

// MARK: Temp Here

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

#if canImport(XCTest)
import XCTest

extension TypedBuilder {
    public func testing(on expectation: XCTestExpectation) -> Self {
        self.base.testing(on: expectation).typed()
    }
}

extension Base {
    public func testing(on expectation: XCTestExpectation) -> Base {
        self.on.either(expectation.fulfill)
            .on.error { err in
                XCTFail("\(err)")
            }
    }
}

#endif
