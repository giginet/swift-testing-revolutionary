import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [ConversionTestFixture] = [
    .init(
        """
        XCTAssert(isValid)
        """,
        """
        #expect(isValid)
        """
    )
]

struct AssertionRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("AssertionRewriter can rewrite all assertions", arguments: fixtures)
    private func rewriteAssertions(_ fixture: ConversionTestFixture) throws {
        let runner = Runner(rewriter: AssertionRewriter(globalOptions: .default))
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
