import Foundation
import SwiftSyntax

extension SyntaxChildren {
    func first(of kind: SyntaxKind) -> Syntax? {
        first { $0.kind == kind }
    }
}

private enum TraversalError: Error {
    case expectedTokenNotFound
}

extension Syntax {
    func dig(kinds: SyntaxKind...) -> Syntax? {
        do {
            return try kinds.reduce(self) { node, kind in
                guard let childNode = node.children(viewMode: .sourceAccurate).first(of: kind) else {
                    throw TraversalError.expectedTokenNotFound
                }
                return childNode
            }
        } catch {
            return nil
        }
    }
}
