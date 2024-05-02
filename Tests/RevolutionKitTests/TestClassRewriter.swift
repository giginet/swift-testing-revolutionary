import Foundation
import Testing
@testable import RevolutionKit

private let structConversionFixtures: [ConversionTestFixtures] = [
    .init(
        source: """
final class HogeTests: XCTestCase {
}
""",
        expected: """
struct HogeTests {
}
"""
    ),
    .init(
        source: """
class HogeTests: XCTestCase {
}
""",
        expected: """
struct HogeTests {
}
"""
    ),
    .init(
        source: """
final class HogeTests: NoTest {
}
""",
        expected: """
struct HogeTests {
}
"""
    ),
    .init(
        source: """
final class NotATestClass {
}
""",
        expected: """
final class NotATestClass {
}
"""
    ),
]

private let classConversionFixtures: [ConversionTestFixtures] = [
    .init(
        source: """
final class HogeTests: XCTestCase {
}
""",
        expected: """
final class HogeTests {
}
"""
    ),
    .init(
        source: """
class HogeTests: XCTestCase {
}
""",
        expected: """
class HogeTests {
}
"""
    ),
    .init(
        source: """
final class HogeTests: NoTest {
}
""",
        expected: """
final class HogeTests {
}
"""
    ),
    .init(
        source: """
final class NotATestClass {
}
""",
        expected: """
final class NotATestClass {
}
"""
    ),
]

private struct TestClassRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("TestClassRewriter can convert test class definitions to struct", arguments: structConversionFixtures)
    private func rewriterCanConvertsToStruct(_ fixture: ConversionTestFixtures) throws {
        let runner = Runner(rewriter: TestClassRewriter(globalOptions: .default))
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
    
    @Test("TestClassRewriter can convert test class definitions to classes", arguments: classConversionFixtures)
    private func rewriterCanConvertsToTests(_ fixture: ConversionTestFixtures) throws {
        let runner = Runner(rewriter: TestClassRewriter(globalOptions: .init(enableStructConversion: false)))
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
