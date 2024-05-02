import Foundation
import SwiftSyntax
import SwiftParser

package struct Runner {
    private let globalOptions: GlobalOptions
    private let rewriter: SyntaxRewriter
    
    init(globalOptions: GlobalOptions = .default) {
        self.globalOptions = globalOptions
        self.rewriter = TestSourceFileRewriter(globalOptions: globalOptions)
    }
    
    init(
        globalOptions: GlobalOptions = .default,
        rewriter: SyntaxRewriter
    ) {
        self.globalOptions = globalOptions
        self.rewriter = rewriter
    }
    
    func run<E: Emitter>(for source: String, emitter: E) -> E.EmitType {
        let sourceFile = Parser.parse(source: source)
        let converted = rewriter.visit(sourceFile)
        return emitter.emit(sourceFileSyntax: converted)
    }
}
