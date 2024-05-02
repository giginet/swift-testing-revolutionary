import Foundation
import SwiftSyntax

extension SyntaxChildren {
    func first(of kind: SyntaxKind) -> Syntax? {
        first { $0.kind == kind }
    }
    
    func first<S: SyntaxProtocol>(of kind: SyntaxKind, as: S.Type) -> S? {
        let syntax = first(of: kind)
        return syntax?.as(S.self)
    }
}

private enum TraversalError: Error {
    case expectedTokenNotFound
}

extension SyntaxProtocol {
    func first<S: SyntaxProtocol>(of kind: SyntaxKind, as: S.Type) -> S? {
        let syntax = children(viewMode: .sourceAccurate).first(of: kind)
        return syntax?.as(S.self)
    }
    
    func traverse(kinds: [SyntaxKind]) -> Syntax? {
        do {
            return try kinds.reduce(_syntaxNode) { node, kind in
                guard let childNode = node.children(viewMode: .sourceAccurate).first(of: kind) else {
                    throw TraversalError.expectedTokenNotFound
                }
                return childNode
            }
        } catch {
            return nil
        }
    }
    
    func traverse<ReturnType: SyntaxProtocol>(kinds: [SyntaxKind], as: ReturnType.Type) -> ReturnType? {
        let abstractSyntax = traverse(kinds: kinds)
        return abstractSyntax?.as(ReturnType.self)
    }
}
