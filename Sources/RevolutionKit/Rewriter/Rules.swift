import Foundation
import SwiftSyntax

protocol RewriteRule {
    static func rewrite(_ token: TokenSyntax) -> TokenSyntax
    static func shouldRewrite(for token: TokenSyntax) -> Bool
}

typealias RuleSets = [any RewriteRule.Type]

struct ImportStatementRule: RewriteRule {
    static func rewrite(_ token: TokenSyntax) -> TokenSyntax {
        precondition(token.tokenKind == .identifier("XCTest"))
        return token.with(\.tokenKind, .identifier("Testing"))
    }
    
    static func shouldRewrite(for token: TokenSyntax) -> Bool {
        token.tokenKind == .identifier("XCTest") &&
        token.previousToken(viewMode: .sourceAccurate)?.tokenKind == .keyword(.import)
    }
}
