import Foundation
import Testing
@testable import RevolutionKit

private let testCaseConversionFixtures: [ConversionTestFixture] = [
    .init(
        """
        func testExample() {
        }
        """,
        """
        @Test func example() {
        }
        """
    ),
    .init(
        """
        func test_do_something() {
        }
        """,
        """
        @Test func do_something() {
        }
        """
    ),
    .init(
        """
        func test() {
        }
        """,
        """
        @Test func test() {
        }
        """
    ),
    .init(
        """
        @MainActor func testExample() {
        }
        """,
        """
        @Test @MainActor func example() {
        }
        """
    ),
    .init(
        """
        @MainActor 
        func testExample() {
        }
        """,
        """
        @Test @MainActor 
        func example() {
        }
        """
    ),

    .init(
        """
        static func testExample() {
        }
        """,
        """
        static func testExample() {
        }
        """
    ),
    .init(
        """
        func notTest() {
        }
        """,
        """
        func notTest() {
        }
        """
    ),
]

private let setUpConversionFixtures: [ConversionTestFixture] = [
    .init(
        """
        func setUp() {
        }
        """,
        """
        init() {
        }
        """
    ),
    .init(
        """
        func setUp() async throws {
        }
        """,
        """
        init() async throws {
        }
        """
    ),
    .init(
        """
        @MainActor func setUp() async throws {
        }
        """,
        """
        @MainActor init() async throws {
        }
        """
    ),
    .init(
        """
        func setUpWithError() throws {
        }
        """,
        """
        init() throws {
        }
        """
    ),
    .init(
        """
        override func setUp() {
        }
        """,
        """
        init() {
        }
        """
    ),
    .init(
        """
        static func setUp() {
        }
        """,
        """
        static func setUp() {
        }
        """
    ),
]

private let tearDownConversionFixtures: [ConversionTestFixture] = [
    .init(
        """
        func tearDown() {
        }
        """,
        """
        deinit {
        }
        """
    ),
    .init(
        """
        func tearDown() async throws {
        }
        """,
        """
        deinit {
        }
        """
    ),
    .init(
        """
        override func tearDown() async throws {
        }
        """,
        """
        deinit {
        }
        """
    ),
    .init(
        """
        static func tearDown() {
        }
        """,
        """
        static func tearDown() {
        }
        """
    ),
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
