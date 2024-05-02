import Foundation
import SwiftSyntax

/// Rewriter for the whole test file. It expects to be used for SourceFileSyntax
class TestSourceFileRewriter: SyntaxRewriter {
    private let globalOptions: GlobalOptions
    private lazy var importStatementRewriter = ImportStatementRewriter()
    private lazy var testClassRewriter = TestClassRewriter(globalOptions: globalOptions)
    
    init(globalOptions: GlobalOptions) {
        self.globalOptions = globalOptions
    }
    
    override func visit(_ node: ImportDeclSyntax) -> DeclSyntax {
        importStatementRewriter.visit(node)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        testClassRewriter.visit(node)
    }
    
    override func visit(_ node: TryExprSyntax) -> ExprSyntax {
        super.visit(node)
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        super.visit(node)
    }
}
