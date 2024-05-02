import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [Fixture] = [
    .init(source: "import XCTest", expected: "import Testing"),
]

private struct ImportStatementRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("All rewriters can convert syntaxes", arguments: fixtures)
    private func rewriter(_ fixture: Fixture) throws {
        let runner = Runner(rewriter: ImportStatementRewriter())
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
