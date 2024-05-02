import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [ConversionTestFixture] = [
    .init("import XCTest", "import Testing"),
    .init("import Foundation", "import Foundation"),
]

private struct ImportStatementRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("All rewriters can convert syntaxes", arguments: fixtures)
    private func rewriter(_ fixture: ConversionTestFixture) throws {
        let runner = Runner(rewriter: ImportStatementRewriter())
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
