import XCTest
@testable import Commons

class LogTests: XCTestCase {
    func testBasic() {
        let test = "real basic: " + UUID().uuidString
        Log.trace(test)
        let pass = Log.outputs.memory!.logs[.trace].map(\.msg).contains(test)
        XCTAssert(pass, "failed to log to memory")
    }
}

class MiscTests: XCTestCase {
    func testPreconditionStuffs() {
        /// #file => #filePath || #fileID
        let preconditions = [
            #fileID.description,
            #filePath.description,
            #line.description,
            #function.description,
            #column.description,
            "\(#dsohandle)",
        ]
        Log.info("preconditions: \(preconditions)")
    }
}

class JSONDataTests: XCTestCase {
    func testJSONLisAccess() throws {
        let arr: [JSON] = (1...10).map { idx in
            ["luckyNumber": .int(idx)]
        }
        let wrapped = JSON.array(arr)
        XCTAssertEqual(wrapped.array?.count, wrapped.luckyNumber?.array?.count)
    }
    
    func testSimpleNestedArray() {
        var json = [
            "lista": [
                [
                    "a": 1
                ],
                [
                    "a": 2
                ]
            ]
        ] as JSON
        
        let val = json.lista._1.a?.int
        XCTAssertEqual(val, 2)
        json.lista._1.newKey = "updated"
        let new = json.lista._1.newKey?.string ?? "<>"
        XCTAssertEqual(new, "updated")
    }
    
    func testNestedArrays() {
        var nested = [
            "another": [
                [
                    "long": [
                        "nesting": [
                            0, 1, 2, 3
                        ]
                    ]
                ]
            ]
        ] as JSON


        let huzzah = "huzzahhhh"
        nested.another._0.long.these.are.all.new = huzzah
        XCTAssertEqual(nested.another._0.long.these.are.all.new, huzzah)
        let value = nested.another._0.long.nesting._2?.int
        XCTAssertEqual(value, 2)
    }
    
    func testJSONLinkedPathTests() throws {
        var json = [
            "here": [
                "is": [
                    "a": [
                        "very": [
                            "long": [
                                "path": "<3"
                            ]
                        ]
                    ]
                ]
            ]
        ] as JSON
        
        let found = json.here.is.a.very.long.path?.string
        XCTAssertEqual(found, "<3")
        let nnneeewww = "nnneeewww"
        json.here.new = nnneeewww
        XCTAssert(try json.encode().string?.contains(nnneeewww) == true)
        json.here.is.a.very.long.update = 411
        XCTAssertEqual(json.here.is.a.very.long.update, 411)
    }
}

class DynmicTests: XCTestCase {
    @dynamicCallable
    @dynamicMemberLookup
    struct Dyno {
        subscript(dynamicMember kp: String) -> Dyno {
            self
        }
        
        func dynamicallyCall(withArguments args: [Any]) {
            print("args: \(args)")
        }
        
        func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) {
            print("args: \(args)")
        }
    }
    
    func testDynamics() {
        let trex = Dyno()
        trex.somedynamicname(1, 2, 4, heyoSwift: ["don't do this": "but useful for interop"])
    }
}
    
class CodableStorageTests: XCTestCase {
    struct Item: Codable, Equatable {
        let id: String
        let value: Int
        
        static let initialAlways: Item = Item(id: "initial-always", value: 88)
        static let initialSometimes: Item? = nil
    }
    
    struct Holder {
        let name: String
        
        @CodableStorage("codable.storage.test.item")
        var always: Item = .initialAlways
        
        @CodableStorage("codable.storage.test.optional")
        var sometimes: Item? = .initialSometimes
    }
    
    func testBasic() {
        var reset = Holder(name: "reset")
        reset.always = .initialAlways
        reset.sometimes = .initialSometimes
        
        var aa = Holder(name: "habba")
        XCTAssertEqual(aa.always, .initialAlways)
        XCTAssertEqual(aa.sometimes, .initialSometimes)
        
        let newSometimes = Item(id: "new-sometimes", value: Int.random(in: 0...838383))
        aa.sometimes = newSometimes
        XCTAssertEqual(aa.sometimes, newSometimes)
        var bb = Holder(name: "vevva")
        XCTAssertNotNil(bb.sometimes)
        XCTAssertEqual(aa.sometimes, bb.sometimes)
        
        let newAlways = Item(id: "dadada", value: 91119)
        bb.always = newAlways
        XCTAssertEqual(bb.always, aa.always)
    }
}

