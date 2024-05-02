import Foundation
import SwiftSyntax

/// Rewriter for the whole test file. It expects to be used for SourceFileSyntax
class TestSourceFileRewriter: SyntaxRewriter {
    private let importStatementRewriter = ImportStatementRewriter()
    
    override func visit(_ node: ImportDeclSyntax) -> DeclSyntax {
        importStatementRewriter.visit(node)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        super.visit(node)
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        super.visit(node)
    }
    
    override func visit(_ node: TryExprSyntax) -> ExprSyntax {
        super.visit(node)
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        super.visit(node)
    }
}