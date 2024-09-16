import Foundation
import Testing
@testable import RevolutionKit

private let structConversionFixtures: [ConversionTestFixture] = [
    Fixture {
        """
        final class HogeTests: XCTestCase {
        }
        """
        """
        @Suite struct HogeTests {
        }
        """
    },
    Fixture {
        """
        class HogeTests: XCTestCase {
        }
        """
        """
        @Suite struct HogeTests {
        }
        """
    },
    Fixture {
        """
        final class HogeTests: NoTest {
        }
        """
        """
        @Suite struct HogeTests {
        }
        """
    },
    Fixture {
        """
        final class NotATestClass {
        }
        """
        """
        final class NotATestClass {
        }
        """
    },
]

private let classConversionFixtures: [ConversionTestFixture] = [
    Fixture {
        """
        final class HogeTests: XCTestCase {
        }
        """
        """
        @Suite final class HogeTests {
        }
        """
    },
    Fixture {
        """
        class HogeTests: XCTestCase {
        }
        """
        """
        @Suite class HogeTests {
        }
        """
    },
    Fixture {
        """
        final class HogeTests: NoTest {
        }
        """
        """
        @Suite final class HogeTests {
        }
        """
    },
    Fixture {
        """
        final class NotATestClass {
        }
        """
        """
        final class NotATestClass {
        }
        """
    },
]

private let structConversionFixturesWithoutSuite: [ConversionTestFixture] = [
    Fixture {
        """
        final class HogeTests: XCTestCase {
        }
        """
        """
        struct HogeTests {
        }
        """
    },
    Fixture {
        """
        class HogeTests: XCTestCase {
        }
        """
        """
        struct HogeTests {
        }
        """
    },
    Fixture {
        """
        final class HogeTests: NoTest {
        }
        """
        """
        struct HogeTests {
        }
        """
    },
    Fixture {
        """
        final class NotATestClass {
        }
        """
        """
        final class NotATestClass {
        }
        """
    },
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
