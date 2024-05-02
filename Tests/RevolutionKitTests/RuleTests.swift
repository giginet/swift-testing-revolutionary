import Foundation
import Testing
import SwiftSyntax
import SwiftParser
@testable import RevolutionKit

private struct Fixture {
    let rule: any RewriteRule.Type
    let source: String
    let expected: String
}

private let fixtures: [Fixture] = [
    .init(rule: ImportStatementRule.self, source: "import XCTest", expected: "import Testing"),
]

private struct RuleTests {
    @Test("All rule can convert syntaxes", arguments: fixtures)
    private func rule(_ fixture: Fixture) throws {
        let runner = Runner(rules: [fixture.rule])
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
