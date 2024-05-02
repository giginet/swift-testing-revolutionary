import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [Fixture] = [
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
final class HogeTests: NoTest {
}
"""
    ),
]

private struct TestClassRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("TestClassRewriter can convert test class definitions", arguments: fixtures)
    private func rewriter(_ fixture: Fixture) throws {
        let runner = Runner(rewriter: TestClassRewriter())
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
