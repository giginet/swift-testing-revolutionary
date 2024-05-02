import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [ConversionTestFixtures] = [
    .init(
        source:
            """
            func testExample() {
            }
            """,
        expected:
            """
            @Test func example() {
            }
            """
    ),
    .init(
        source:
            """
            static func testExample() {
            }
            """,
        expected:
            """
            static func testExample() {
            }
            """
    ),
    .init(
        source:
            """
            func notTest() {
            }
            """,
        expected:
            """
            func notTest() {
            }
            """
    ),
]

struct TestMethodsRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("All rewriters can convert syntaxes", arguments: fixtures)
    private func rewriter(_ fixture: ConversionTestFixtures) throws {
        let runner = Runner(rewriter: TestMethodsRewriter(globalOptions: .default))
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
