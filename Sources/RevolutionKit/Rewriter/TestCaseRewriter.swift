import Foundation
import SwiftSyntax

/// Rewriter to XCTest test cases to swift-testing.
final class TestCaseRewriter: SyntaxRewriter {
    override func visit(_ token: TokenSyntax) -> TokenSyntax {
        guard token.tokenKind == .identifier("XCTest") &&
                token.previousToken(viewMode: .sourceAccurate)?.tokenKind == .keyword(.import) else {
            return token
        }
        
        return token.with(\.tokenKind, .identifier("Testing"))
    }
}
