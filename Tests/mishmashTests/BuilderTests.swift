import XCTest
@testable import Commons
@testable import Endpoints

struct Levels {
    
}

protocol LogID {
    var symbol: Character { get }
    var id: String { get }
}

final class BuilderTests: XCTestCase {
    func testBuilder() {
        struct Ob {
            var a = ""
            var b = ""
        }

        let aaas = Builder(Ob.init)
            .a("aaa")

        let l = aaas.b("l").make()
        let r = aaas.b("r").make()

        XCTAssertEqual(l.a, "aaa")
        XCTAssertEqual(l.a, r.a)
        XCTAssertEqual(l.b, "l")
        XCTAssertEqual(r.b, "r")
    }

    func testValidating() {
        struct Adult: ValidatingModel {
            var name = ""
            var age = 0

            var isReady: (ready: Bool, help: String) {
                guard age >= 1000 else { return (false, "acquire wisdom") }
                return (true, help: "ok")
            }
        }

        let builder = Builder(Adult.init)
        do {
            _ = try builder.make()
            XCTFail("object should throw")
        } catch {
            // purposeful error
        }
    }

    func testNested() {
        struct Inny {
            var a = ""
            var b = ""
            var thirdsy = Thirdsy()

            struct Thirdsy {
                var alt = "setting a different way"
                var moar = "triple nested"
            }
        }

        struct Outy {
            var ooo: Int = 929
            var iii: Inny = .init()
        }
        let header = Builder(Outy.init)
            .iii { value in
                value
                    .a("will be overwritten")
                    .b("returns")
                    .thirdsy.moar("terple")
            }
            .ooo(10_000)

        let builder = header
            .iii.a("asfd")
            /// should overwrite
            .iii.a("sets")
            .iii.thirdsy.alt("pahthz")


        let outy = builder()
        XCTAssertEqual(outy.iii.a, "sets")
        XCTAssertEqual(outy.iii.b, "returns")
        XCTAssertEqual(outy.ooo, 10_000)
        XCTAssertEqual(outy.iii.thirdsy.moar, "terple")
        XCTAssertEqual(outy.iii.thirdsy.alt, "pahthz")
    }

    func testNest() {
        class Matrushka {
            var name: String = ""
            var next: Later<Matrushka> = Later { Matrushka() }
        }

        class DollPerson {
            var base = Matrushka()
        }

        let dollPerson = Builder(DollPerson.init)
            .base
            .next.wrappedValue
            .next.wrappedValue
            .next.wrappedValue
            .name("flensi")
            .make()

        var last: Matrushka = dollPerson.base
        XCTAssertEqual(last.name, "")

        while last.next.hasLoaded  {
            last = last.next()
        }
        XCTAssertEqual(last.name, "flensi")
    }


    private static var dbstuff = false
    func testActionModel() {
        struct DatabaseFetch: ActionModel {
            var query: String = ""
            var permissions: [Int] = []

            func callAsFunction() {
                // do db stuff
                BuilderTests.dbstuff = true
            }
        }

        Builder(DatabaseFetch.init)
            .query("user=='me'")
            .permissions([3,5,6])
            .run()

        XCTAssertTrue(BuilderTests.dbstuff, "action model didn't fire")
    }

    func testConstructs() {
        class A {
            var larb: Int = 0
        }
        struct B {
            var vlarn: Int = 0
            var a: A = .init()
        }

        let build = Builder(B.init)
        let down = build.a.larb(22)
        let the = down
            .a { subBuilder in
                subBuilder.larb(if: true, 424)
            }

        let chain = the.make()
        (1...5).forEach { _ in
            XCTAssertEqual(the().a.larb, 424)
            XCTAssertEqual(down().a.larb, 22)
        }

        XCTAssertEqual(chain.a.larb, 424)
    }

    func testDemo() {
        var text: String { "demo" }

        func function(with: Int = 0, arguments: String = "", here: [String] = []) {
            Log.info(with.description + arguments + here.joined(separator: ", "))
        }

        struct Instead: ActionModel {
            var with: Int = 0
            var arguments: String = ""
            var here: [String] = []

            func callAsFunction() {
                Log.info(with.description + arguments + here.joined(separator: ", "))
            }
        }

        let instead = Builder(Instead.init)

        func example() {
            function(with: 3, arguments: "hiya", here: ["oinobo"])
            instead.with(3).arguments("hiya").here(["obniboo"]).run()

            // essentially currying the struct, any order, can divere paths
            let threes = instead.with(333333).here(["out of order calling, oh my"])
            let a = threes.arguments(" a ").make()
            let b = threes.arguments(" b ").make()

            // when user enters the sub builder, it gives warnings that the result is unused
            instead.with(3).arguments("ayii").here(["cool"])
        }

        example()
    }
}
