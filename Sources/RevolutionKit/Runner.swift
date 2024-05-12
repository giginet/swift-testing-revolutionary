import Foundation
import SwiftSyntax
import SwiftParser

package struct Runner {
    private let globalOptions: GlobalOptions
    private let rewriter: SyntaxRewriter
    
    package init(globalOptions: GlobalOptions = .default) {
        self.globalOptions = globalOptions
        self.rewriter = XCTestRewriter(globalOptions: globalOptions)
    }
    
    init(
        globalOptions: GlobalOptions = .default,
        rewriter: SyntaxRewriter
    ) {
        self.globalOptions = globalOptions
        self.rewriter = rewriter
    }
    
    package func run(for sources: [URL]) async throws {
        let testFileFinder = TestFileFinder()
        
        let allTestFiles = testFileFinder.findTestFiles(in: sources)
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for testFile in allTestFiles {
                group.addTask {
                    try run(for: testFile, emitter: StringEmitter())
                }
            }
        }
    }
    
    @discardableResult
    func run<E: Emitter>(for sourceFile: URL, emitter: E) throws -> E.EmitType {
        let data = try Data(contentsOf: sourceFile)
        guard let sourceContents = String(data: data, encoding: .utf8) else {
            throw Error.unableToLoadSource(at: sourceFile)
        }
        return run(for: sourceContents, emitter: emitter)
    }
    
    @discardableResult
    func run<E: Emitter>(for source: String, emitter: E) -> E.EmitType {
        let sourceFile = Parser.parse(source: source)
        let converted = rewriter.rewrite(sourceFile, detach: true)
        return emitter.emit(converted)
    }
}

extension Runner {
    enum Error: LocalizedError {
        case unableToLoadSource(at: URL)
    }
}
