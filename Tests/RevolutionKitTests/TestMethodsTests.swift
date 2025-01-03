import Foundation
import Testing
@testable import RevolutionKit

private let testCaseConversionFixtures: [ConversionTestFixture] = [
    Fixture {
        """
        func testExample() {
        }
        """
        """
        @Test func example() {
        }
        """
    },
    Fixture {
        """
        func test_do_something() {
        }
        """
        """
        @Test func do_something() {
        }
        """
    },
    Fixture {
        """
        func test() {
        }
        """
        """
        @Test func test() {
        }
        """
    },
    Fixture {
        """
        @MainActor func testExample() {
        }
        """
        """
        @Test @MainActor func example() {
        }
        """
    },
    Fixture {
        """
        @MainActor 
        func testExample() {
        }
        """
        """
        @Test @MainActor 
        func example() {
        }
        """
    },

    Fixture {
        """
        static func testExample() {
        }
        """
        """
        static func testExample() {
        }
        """
    },
    Fixture {
        """
        func notTest() {
        }
        """
        """
        func notTest() {
        }
        """
    },
    Fixture {
        """
        private func testExample() {
        }
        """
        """
        private func testExample() {
        }
        """
    },
    Fixture {
        """
        private static func testExample() {
        }
        """
        """
        private static func testExample() {
        }
        """
    },
]

private let setUpConversionFixtures: [ConversionTestFixture] = [
    Fixture {
        """
        func setUp() {
        }
        """
        """
        init() {
        }
        """
    },
    Fixture {
        """
        func setUp() async throws {
        }
        """
        """
        init() async throws {
        }
        """
    },
    Fixture {
        """
        @MainActor func setUp() async throws {
        }
        """
        """
        @MainActor init() async throws {
        }
        """
    },
    Fixture {
        """
        func setUpWithError() throws {
        }
        """
        """
        init() throws {
        }
        """
    },
    Fixture {
        """
        override func setUp() {
        }
        """
        """
        init() {
        }
        """
    },
    Fixture {
        """
        static func setUp() {
        }
        """
        """
        static func setUp() {
        }
        """
    },
]

private let tearDownConversionFixtures: [ConversionTestFixture] = [
    Fixture {
        """
        func tearDown() {
        }
        """
        """
        deinit {
        }
        """
    },
    Fixture {
        """
        func tearDown() async throws {
        }
        """
        """
        deinit {
        }
        """
    },
    Fixture {
        """
        override func tearDown() async throws {
        }
        """
        """
        deinit {
        }
        """
    },
    Fixture {
        """
        static func tearDown() {
        }
        """
        """
        static func tearDown() {
        }
        """
    },
]

@Suite struct TestMethodsTests {
    private let emitter = StringEmitter()
    
    @Test("TestMethodsRewriter can convert test cases", arguments: testCaseConversionFixtures)
    private func rewriteTestCases(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner()
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
    
    @Test("TestMethodsRewriter can convert setUp methods", arguments: setUpConversionFixtures)
    private func rewriteSetUps(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner()
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
    
    @Test("TestMethodsRewriter can convert tearDown methods", arguments: tearDownConversionFixtures)
    private func rewriteTearDowns(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner()
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
}
