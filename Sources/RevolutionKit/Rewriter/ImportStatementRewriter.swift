import Foundation
import SwiftSyntax

/// Rewriter to replace `XCTest` imports with `Testing`.
final class ImportStatementRewriter: SyntaxRewriter {
    override func visit(_ node: ImportDeclSyntax) -> DeclSyntax {
        guard let importPathComponent = node.traverse(kinds: [.importPathComponentList, .importPathComponent], as: ImportPathComponentSyntax.self) else {
            return super.visit(node)
        }
        
        let newNode = ImportDeclSyntax(
            path: ImportPathComponentListSyntax([
                importPathComponent.with(\.name, .identifier("Testing"))
            ])
        )
        
        return super.visit(DeclSyntax(newNode))
    }
}
