import Foundation
import Testing
@testable import RevolutionKit

private let structConversionFixtures: [ConversionTestFixture] = [
    .init(
        """
        final class HogeTests: XCTestCase {
        }
        """,
        """
        @Suite struct HogeTests {
        }
        """
    ),
    .init(
        """
        class HogeTests: XCTestCase {
        }
        """,
        """
        @Suite struct HogeTests {
        }
        """
    ),
    .init(
        """
        final class HogeTests: NoTest {
        }
        """,
        """
        @Suite struct HogeTests {
        }
        """
    ),
    .init(
        """
        final class NotATestClass {
        }
        """,
        """
        final class NotATestClass {
        }
        """
    ),
]

private let classConversionFixtures: [ConversionTestFixture] = [
    .init(
        """
        final class HogeTests: XCTestCase {
        }
        """,
        """
        @Suite final class HogeTests {
        }
        """
    ),
    .init(
        """
        class HogeTests: XCTestCase {
        }
        """,
        """
        @Suite class HogeTests {
        }
        """
    ),
    .init(
        """
        final class HogeTests: NoTest {
        }
        """,
        """
        @Suite final class HogeTests {
        }
        """
    ),
    .init(
        """
        final class NotATestClass {
        }
        """,
        """
        final class NotATestClass {
        }
        """
    ),
]

private let structConversionFixturesWithoutSuite: [ConversionTestFixture] = [
    .init(
        """
        final class HogeTests: XCTestCase {
        }
        """,
        """
        struct HogeTests {
        }
        """
    ),
    .init(
        """
        class HogeTests: XCTestCase {
        }
        """,
        """
        struct HogeTests {
        }
        """
    ),
    .init(
        """
        final class HogeTests: NoTest {
        }
        """,
        """
        struct HogeTests {
        }
        """
    ),
    .init(
        """
        final class NotATestClass {
        }
        """,
        """
        final class NotATestClass {
        }
        """
    ),
]

@Suite struct TestSuiteClassTests {
    private let emitter = StringEmitter()
    
    @Test("TestClassRewriter can convert test class definitions to struct", arguments: structConversionFixtures)
    private func rewriterCanConvertsToStructs(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner()
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
    
    @Test("TestClassRewriter can convert test class definitions to classes", arguments: classConversionFixtures)
    private func rewriterCanConvertsToClasses(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner(globalOptions: .init(enableStructConversion: false))
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
    
    @Test("TestClassRewriter can convert test class definitions to struct without @Suite", arguments: structConversionFixturesWithoutSuite)
    private func rewriterCanConvertsToStructsWithoutSuite(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner(globalOptions: .init(enableAddingSuite: false))
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
}
