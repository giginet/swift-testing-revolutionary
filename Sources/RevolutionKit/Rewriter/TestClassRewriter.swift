import Foundation
import SwiftSyntax

final class TestClassRewriter: SyntaxRewriter {
    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        guard let inheritedTypeSyntaxNode = node.traverse(kinds: [.inheritanceClause, .inheritedTypeList, .inheritedType], as: InheritedTypeSyntax.self) else {
            return super.visit(node)
        }
        guard inheritedTypeSyntaxNode.firstToken(viewMode: .sourceAccurate)?.tokenKind == .identifier("XCTestCase") else {
            return super.visit(node)
        }
        
        let newNode = node
            .with(\.classKeyword, .keyword(.struct, trailingTrivia: .spaces(1)))
            .with(\.modifiers, []) // get rid of 'final' keyword
            .with(\.inheritanceClause, InheritanceClauseSyntax(
                colon: .unknown(""),
                inheritedTypes: [],
                trailingTrivia: .spaces(1))
            )
            .with(\.unexpectedBetweenNameAndGenericParameterClause, UnexpectedNodesSyntax())
        
        return DeclSyntax(newNode)
    }
}
