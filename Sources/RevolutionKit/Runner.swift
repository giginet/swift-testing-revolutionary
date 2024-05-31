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
        
        let isDryRunMode = globalOptions.isDryRunMode
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for testFile in allTestFiles {
                group.addTask {
                    let emitter = emitter(for: testFile, isDryRunMode: isDryRunMode)
                    
                    try run(for: testFile, emitter: emitter)
                }
            }
            try? await group.waitForAll()
        }
    }
    
    private func emitter(for testFile: URL, isDryRunMode: Bool) -> any Emitter {
        if isDryRunMode {
            DryRunEmitter(filePath: testFile)
        } else {
            OverwriteEmitter(filePath: testFile)
        }
    }
    
    @discardableResult
    func run<E: Emitter>(for sourceFile: URL, emitter: E) throws -> E.EmitType {
        let fileName = sourceFile.lastPathComponent
        print("Converting \(fileName)")
        guard let data = FileManager.default.contents(atPath: sourceFile.path()),
                let sourceContents = String(data: data, encoding: .utf8) else {
            throw Error.unableToLoadSource(at: sourceFile)
        }
        return try run(for: sourceContents, emitter: emitter)
    }
    
    @discardableResult
    func run<E: Emitter>(for source: String, emitter: E) throws -> E.EmitType {
        let sourceFile = Parser.parse(source: source)
        let converted = rewriter.rewrite(sourceFile, detach: true)
        return try emitter.emit(converted)
    }
}

extension Runner {
    enum Error: LocalizedError {
        case unableToLoadSource(at: URL)
    }
}
