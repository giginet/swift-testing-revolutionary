import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [ConversionTestFixtures] = [
    .init(source: "import XCTest", expected: "import Testing"),
    .init(source: "import Foundation", expected: "import Foundation"),
]

private struct ImportStatementRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("All rewriters can convert syntaxes", arguments: fixtures)
    private func rewriter(_ fixture: ConversionTestFixtures) throws {
        let runner = Runner(rewriter: ImportStatementRewriter())
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
