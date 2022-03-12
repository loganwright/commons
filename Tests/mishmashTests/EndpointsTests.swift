import Foundation
import XCTest
@testable import Commons
@testable import Endpoints

extension Root {
    static var httpbin: Root { Root("httpbin.org") }
}

extension Endpoint {
    var testGet: Endpoint { "get" }
    var users: Endpoint { "users" }
    var api: Endpoint { "api/v{version}/" }
}

typealias EndpointRequest = Request

class EndpointsTests: XCTestCase {
    func testNotes() {
        Log.warn("should change name? ambiguous w Foundation.Host")
    }
    
    func testVersionReplacement() {
        let url = Root.httpbin.api(version: 0).expandedUrl
        XCTAssertEqual(url, "https://httpbin.org/api/v0/")
    }
    
    func testUrlParts() {
        let raw = "https://api-test.padcaster-core.com/api/v0/files/commit/?args=%7B%22user%22%3A+1%2C+%22file%22%3A+114%2C+%22target%22%3A+5%2C+%22name%22%3A+%22BigBuckBunny.ogv+-+COPY+-+1%22%7D.1645788163.5bf321ca3e683807aee13904a536c614c7be1710b0f3362eba92d487d0d43bc5"
        let base = Root(raw)
        XCTAssertEqual(base.baseUrl, "https://api-test.padcaster-core.com")
        XCTAssertEqual(base._path, "/api/v0/files/commit/")
        XCTAssert(base._query?.args?.string?.isEmpty == false)
    }
    
    func testCamelcaseSplit() {
        let comps = "iAmCamelCase".camelcaseComponents
        XCTAssertEqual(comps, ["i", "Am", "Camel", "Case"])
    }
    
    func testHeadersDynamic() {
        let b = Root.httpbin
            .h.xCustomHeader("my-custom-val")
            
        XCTAssertEqual(b._headers, ["X-Custom-Header": "my-custom-val"])
    }
    
    func testUrlId() {
        let base = Root("https://someurl.com/")
            .users
            .get()
            
        XCTAssertEqual(base.expandedUrl, "https://someurl.com/users")
        
        let ided = base.id("1235/")
        XCTAssertEqual(ided.expandedUrl, "https://someurl.com/users/1235/")
        
        
        let direct = Root("https://someurl.com/")
            .users(1235, "/")
        XCTAssertEqual(direct.expandedUrl, "https://someurl.com/users/1235/")
        
        let multi = Root("https://someurl.com/")
            .get("users", 1235, "/")
        XCTAssertEqual(multi.expandedUrl, "https://someurl.com/users/1235/")
    }
    
    func testSimple() {
        XCTAssertEqual(Root("someurl.com").expandedUrl, "https://someurl.com")
    }
    
    func testPathAPIOptions() {
        let a = Root.httpbin.post("users", 1235, "/")
        let b = Root.httpbin.post.users(1235, "/")
        let c = Root.httpbin.post.users.id(1235, enforceTrailingSlash: true)
        let d = Root.httpbin.post.users.id("1235/")
        let e = Root.httpbin.post.users.id(1235).path("/")
        let f = Root.httpbin.post("users/{id}/", id: 1235)
        let g = Root.httpbin.post(path: "users/{id}/", id: 1235)
        let h = Root.httpbin.post(path: "{multiple}/{values}/", multiple: "users", values: 1235)
        let all = [
            a, b, c, d, e, f, g, h
        ]
        XCTAssertEqual(all.map(\.expandedUrl).set.count, 1)
        XCTAssertEqual("https://httpbin.org/users/1235/", a.expandedUrl)
    }
    
    struct Person: Codable, Equatable, Hashable {
        let name: String
        let age: Int
    }
    
    func testQueryAPIOptions() {
        let a = Root.httpbin.get.query(name: "flia", age: 234)
        let b = Root.httpbin.get.query.name("flia").age(234) as Root
        let flia = Person(name: "flia", age: 234)
        let c = Root.httpbin.get.query(flia)
        let d = Root.httpbin.get.q(name: "flia", age: 234)
        let e = Root.httpbin.get.q.name("flia").q.age(234) as Root
        let all = [
            a, b, c, d, e
        ]
        XCTAssertEqual(all.map(\.expandedUrl).set.count, 1, "all query apis should create same url")
        XCTAssertEqual(all[0].expandedUrl, "https://httpbin.org?age=234&name=flia")
    }
    
    func testQueryArrayEncoding() {
        let a = Root.httpbin.get.query(numbers: [1, 4, 6])
        let b = Root.httpbin.get.query.numbers([1, 4, 6]) as Root
        struct Object: Encodable {
            var numbers: [Int] = [1, 4, 6]
        }
        let obj = Object()
        let c = Root.httpbin.get.query(obj)
        let d = Root.httpbin.get.q(numbers: [1, 4, 6])
        let e = Root.httpbin.get.q.numbers([1, 4, 6]) as Root
        let all = [
            a, b, c, d, e
        ]
        let final = all.map(\.expandedUrl).set.first
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "https://httpbin.org?numbers=1,4,6")
        
        let multikey = all.map { $0.encodeQueryArrays(using: .multiKeyed) }.map(\.expandedUrl).set.first
        XCTAssertNotNil(multikey)
        XCTAssertEqual(multikey, "https://httpbin.org?numbers=1&numbers=4&numbers=6")
    }
    
    func testBodyAPIOptions() throws {
        let a = Root.httpbin.post.body(name: "flia", age: 234)
        let b = Root.httpbin.post.body.name("flia").age(234) as Root
        let flia = Person(name: "flia", age: 234)
        let c = Root.httpbin.post.body(flia)
        let d = Root.httpbin.post.b(name: "flia", age: 234)
        let e = Root.httpbin.post.b.name("flia").q.age(234) as Root
        let all = [
            a, b, c, d, e
        ]
        let final = try all.map { try $0.makeRequest() } .compactMap(\.httpBody) .set .first
        XCTAssertNotNil(final)
        XCTAssertEqual(try final?.decode(), flia)
    }

    func testOrdered() throws {
        let orderedTestCases = [
            ("testBearer", testBearer),
            ("testBasicManual", testBasicManual),
            ("testGet", testGet),
            ("testPost", testPost),
            ("testError", testError),
            ("testBasicAuth", testBasicAuth),
            ("testSerialize", testSerialize),
        ]

        orderedTestCases.forEach(execute)
    }
    
    func testBearer(_ group: XCTestExpectation) {
        Root.httpbin
            .get("bearer")
            .bearer(token: "some-user-token-here")
            .on.success { resp in
                XCTAssertEqual(resp.token, "some-user-token-here")
                XCTAssertEqual(resp.authenticated?.bool, true)
            }
            .testing(on: group)
            .send()
    }

    func testBasicManual(_ group: XCTestExpectation) {
        Root("httpbin.org")
            .h.contentType("application/json")
            .h.accept("application/json")
            .h("X-App-Custom", "customval")
            .q.admin(true)
            .testing(on: group)
            .send()
    }
    
    func testGet(_ group: XCTestExpectation) {
        Root.httpbin
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
            .q(name: "flia", age: 234)
            .client(TrafficObserver.default)
            .on.success { json in
                XCTAssertEqual(json.args?.name?.string, "flia")
                XCTAssertEqual(json.args?.age?.int, 234)
            }
            .testing(on: group)
            .send()
    }

    func testPost(_ group: XCTestExpectation) {
        Root.httpbin.post("post")
            .h.contentType("application/type")
            .h.accept("application/json")
            .body(name: "flia", age: 234)
            /// the data is nested
            .extracting(dataPath: \.json)
            .typed(as: Person.self)
            .on.success { flia in
                let p = Person(name: "flia", age: 234)
                XCTAssertEqual(flia, p)
//                XCTAssertEqual(flia.age, 234)
            }
            .on.error { err in
                Log.info("")
            }
            .testing(on: group)
            .send()
    }

    func testError(_ group: XCTestExpectation) {
        Root.httpbin
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
        Root.httpbin
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
        Root("https://httpbin.org")
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

extension Root {
    func basicAuth(user: String, password: String) -> Root {
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

extension Root {
    public func testing(on expectation: XCTestExpectation) -> Root {
        self.on.either(expectation.fulfill)
            .on.error { err in
                XCTFail("\(err)")
            }
    }
}

#endif
