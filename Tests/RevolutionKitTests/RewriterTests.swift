import Foundation
import Testing
import SwiftSyntax
@testable import RevolutionKit

private struct Fixture {
    let rewriter: SyntaxRewriter
    let source: String
    let expected: String
}

private let fixtures: [Fixture] = [
    .init(rewriter: ImportStatementRewriter(), source: "import XCTest", expected: "import Testing"),
]

private struct RewriterTests {
    private let emitter = StringEmitter()
    
    @Test("All rewriters can convert syntaxes", arguments: fixtures)
    private func rewriter(_ fixture: Fixture) throws {
        let runner = Runner(rewriter: fixture.rewriter)
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
