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

private let classConversionFixtures: [ConversionTestFixture] = [
    .init(
        """
        final class HogeTests: XCTestCase {
        }
        """,
        """
        final class HogeTests {
        }
        """
    ),
    .init(
        """
        class HogeTests: XCTestCase {
        }
        """,
        """
        class HogeTests {
        }
        """
    ),
    .init(
        """
        final class HogeTests: NoTest {
        }
        """,
        """
        final class HogeTests {
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

struct TestSuiteClassTests {
    private let emitter = StringEmitter()
    
    @Test("TestClassRewriter can convert test class definitions to struct", arguments: structConversionFixtures)
    private func rewriterCanConvertsToStruct(_ fixture: ConversionTestFixture) throws {
        let runner = Runner()
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
    
    @Test("TestClassRewriter can convert test class definitions to classes", arguments: classConversionFixtures)
    private func rewriterCanConvertsToTests(_ fixture: ConversionTestFixture) throws {
        let runner = Runner(globalOptions: .init(enableStructConversion: false))
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected, sourceLocation: fixture.sourceLocation)
    }
}
