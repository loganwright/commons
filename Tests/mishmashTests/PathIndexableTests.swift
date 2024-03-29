import XCTest
@testable import Commons

class PathIndexableTests: XCTestCase {
    func testString() {
        let array: JSON = ["one",
                           "two",
                           "three"]
        guard let json = array[1] else {
            XCTFail()
            return
        }
        guard case let .string(val) = json else {
            XCTFail()
            return
        }

        XCTAssert(val == "two")
    }

    func testInt() {
        let object: JSON = ["a" : 1]
        guard let json = object["a"] else {
            XCTFail()
            return
        }
        guard case let .int(val) = json else {
            XCTFail()
            return
        }

        XCTAssert(val == 1)
    }

    func testStringSequenceObject() {
        let sub: JSON = ["path" : "found me!"]
        let ob: JSON = ["key" : sub]
        guard let json = ob["key", "path"] else {
            XCTFail()
            return
        }
        guard case let .string(val) = json else {
            XCTFail()
            return
        }
        
        XCTAssert(val == "found me!")
    }

    func testStringSequenceArray() {
        let zero: JSON = ["a" : 0]
        let one: JSON = ["a" : 1]
        let two: JSON = ["a" : 2]
        let three: JSON = ["a" : 3]
        let obArray: JSON = [zero, one, two, three]

        guard let collection = obArray["a"] else {
            XCTFail()
            return
        }
        guard case let .array(value) = collection else {
            XCTFail()
            return
        }

        let mapped: [Double] = value.compactMap(\.double)
        XCTAssert(mapped == [0,1,2,3])
    }

    func testIntSequence() {
        let inner: JSON = ["...", "found me!"]
        let outer = JSON([inner])

        guard let json = outer[0, 1] else {
            XCTFail()
            return
        }
        guard case let .string(value) = json else {
            XCTFail()
            return
        }

        XCTAssert(value == "found me!")
    }

    func testMixed() {
        let array: JSON = [
            "a",
            "b",
            "c",
        ]
        let mixed: JSON = ["one" : array]

        guard let json = mixed["one", 1] else {
            XCTFail()
            return
        }
        guard case let .string(value) = json else {
            XCTFail()
            return
        }

        XCTAssert(value == "b")
    }

    func testAppendItem() {
        var array: JSON = [1.0, 2.0, 3.0]
        XCTAssertNil(array[3])
        /// inserting next index appends
        array[3] = 4.0
        XCTAssertNotNil(array[3])
    }

    func testSetArray() {
        var array: JSON = [1.0, 2.0, 3.0]
        XCTAssertEqual(array[1], 2.0)
        array[1] = 4.0
        XCTAssertEqual(array[1], 4.0)
        array[1] = nil
        XCTAssertEqual(array[1], 3.0)
    }

    func testMakeEmpty() {
        let int: Int = 5
        let json: JSON = int.makeEmptyStructureForIndexing()
        XCTAssertEqual(json, [])
    }

    func testAccessNil() {
        let array: JSON = [["test": 42], 5]
        Log.info(type(of: array["foo"]))
        XCTAssertNil(array["foo"])
        
        if let keyValResult = array["test"], case let .array(array) = keyValResult {
            XCTAssertEqual(array.count, 1)
            XCTAssertEqual(array.first, 42)
        } else {
            XCTFail("Expected array result from array key val")
        }

        let number = JSON.int(5)
        XCTAssertNil(number["test"])
    }

    func testSetObject() {
        var object: JSON = [
            "one": 1.0,
            "two": 2.0,
            "three": 3.0
        ]
        XCTAssertEqual(object["two"], 2.0)
        object["two"] = 4.0
        XCTAssertEqual(object["two"], 4.0)
        object["two"] = nil
        XCTAssertEqual(object["two"], nil)

        var array: JSON = [object, object]
        array["two"] = 5.0
    }

    func testPath() {
        var object: JSON = [
            "one": [
                "two": 42
            ]
        ]
        XCTAssertEqual(object["one.two"], 42)

        object["one.two"] = 5
        XCTAssertEqual(object["one.two"], 5)

        let comps = "one.two.5.&".unwrapComponents() as! [String]
        XCTAssertEqual(comps, ["one", "two", "5", "&"])
    }

    func testStringPathIndex() {
        let path = ["hello", "3"]
                let json: JSON = [
                    "hello": [
                        "a",
                        "b",
                        "c",
                        "d",
                    ]
                ]

        if let n = json[path], case let .string(result) = n {
            XCTAssert(result == "d")
        } else {
            XCTFail("Expected result")
        }
    }

    func testDotKey() {
        let json: JSON =
        [
            "foo.bar": [
                "a",
                "b",
                "c",
                "d",
            ]
        ]
        
        if let n = json[DotKey("foo.bar"), 3], case let .string(result) = n {
            XCTAssert(result == "d")
        } else {
            XCTFail("Expected result")
        }
    }
}
