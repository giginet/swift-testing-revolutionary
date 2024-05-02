import Foundation
import SwiftSyntax

final class ImportStatementRewriter: SyntaxRewriter {
    override func visit(_ token: TokenSyntax) -> TokenSyntax {
        guard token.tokenKind == .identifier("XCTest") &&
                token.previousToken(viewMode: .sourceAccurate)?.tokenKind == .keyword(.import) else {
            return token
        }
        
        return token.with(\.tokenKind, .identifier("Testing"))
    }
}