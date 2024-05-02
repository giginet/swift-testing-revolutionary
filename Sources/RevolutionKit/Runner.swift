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

private let defaultRuleSets = [
    ImportStatementRule.self,
]

package struct Runner {
    private let rewriter: TestSourceFileRewriter
    
    init(rules: RuleSets = defaultRuleSets) {
        rewriter = .init(rules: rules)
    }
    
    func run<E: Emitter>(for source: String, emitter: E) -> E.EmitType {
        let sourceFile = Parser.parse(source: source)
        let converted = rewriter.visit(sourceFile)
        return emitter.emit(sourceFileSyntax: converted)
    }
}
