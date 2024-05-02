import Foundation
import SwiftSyntax

class TestCaseRewriter: SyntaxRewriter {
    private let rules: [any RewriteRule.Type] = [
        ImportStatementRule.self,
    ]
    
    override func visit(_ token: TokenSyntax) -> TokenSyntax {
        let newToken = rules.reduce(token) { token, rule in
            guard rule.shouldRewrite(for: token) else { return token }
            return rule.rewrite(token)
        }
        return super.visit(newToken)
    }
}
