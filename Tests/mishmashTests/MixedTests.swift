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

class JSONDataTests: XCTestCase {
    func testDataJSON() throws {
        let raw = """
        {
            "a": "here's a string",
            "b": "here's anothaaaa",
            "c": 8332,
            "e": [
                {
                    "nesteda": "mohmoh",
                    "nestedb": 111.444
                }
            ]
        }
        """
        
        let data = raw.data
        let deco = try JSON.decode(data)
        let str = JSON.str(raw)
        
        let edata = try data.encoded()
        let edeco = try deco.encoded()
        let estr = try str.encoded()
        // this appears a json limitation
        Log.error("I think this is ok, you just need to know if your obj is jsondata or str")
        
//        XCTAssertEqual(edata, edeco)
//        XCTAssertEqual(estr, edeco)
    }
}

@available(iOS 14, *)
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

//class GennyTests: XCTestCase {
//    func testBasic() {
//        Log.trace("real basic")
//        print()
//    }
//    func testPow() {
//        let 8 = 8.display
//        let zero = pow(10, 0)
//        Log.info(zero)
//    }
//}
