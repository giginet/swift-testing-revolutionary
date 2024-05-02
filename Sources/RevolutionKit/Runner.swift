import Foundation
import SwiftSyntax
import SwiftParser

protocol Emitter {
    associatedtype EmitType
    
    func emit(sourceFileSyntax: SourceFileSyntax) -> EmitType
}

struct StringEmitter: Emitter {
    typealias EmitType = String
    
    func emit(sourceFileSyntax: SourceFileSyntax) -> EmitType {
        sourceFileSyntax.description
    }
}

package struct Runner {
    private let rewriter: SyntaxRewriter
    
    init(rewriter: SyntaxRewriter = TestSourceFileRewriter()) {
        self.rewriter = rewriter
    }
    
    func run<E: Emitter>(for source: String, emitter: E) -> E.EmitType {
        let sourceFile = Parser.parse(source: source)
        let converted = rewriter.visit(sourceFile)
        return emitter.emit(sourceFileSyntax: converted)
    }
}
