import Foundation
import SwiftSyntax

/// Rewriter for the whole test file. It expects to be used for SourceFileSyntax
class TestSourceFileRewriter: SyntaxRewriter {
    private let rules: RuleSets
    private let importStatementRewriter = ImportStatementRewriter()
    
    init(rules: [any RewriteRule.Type]) {
        self.rules = rules
    }
    
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
//    
//    override func visit(_ token: TokenSyntax) -> TokenSyntax {
//        let newToken = rules.reduce(token) { token, rule in
//            guard rule.shouldRewrite(for: token) else { return token }
//            return rule.rewrite(token)
//        }
//        return super.visit(newToken)
//    }
}
