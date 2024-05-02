import Foundation
import Testing
@testable import RevolutionKit

struct RunnerTests {
    private let runner = Runner()

    @Test
    func replaceImportStatement() {
        let source = "import XCTest"
        let converted = runner.run(for: source, emitter: StringEmitter())
        #expect(converted == "import Testing")
    }
}
