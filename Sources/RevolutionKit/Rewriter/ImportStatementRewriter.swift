import Foundation
import SwiftSyntax

/// Rewriter to replace `XCTest` imports with `Testing`.
extension TestSourceFileRewriter {
    func visitForImportDecl(_ node: ImportDeclSyntax) -> DeclSyntax {
        guard let importPathComponent = node.traverse(kinds: [.importPathComponentList, .importPathComponent], as: ImportPathComponentSyntax.self),
              importPathComponent.name.tokenKind == .identifier("XCTest")
        else {
            return super.visit(node)
        }
        
        let newPath = ImportPathComponentListSyntax([
            importPathComponent
                .with(\.name, .identifier("Testing"))
                .with(\.leadingTrivia, .space)
        ])
        
        let newNode = node.with(\.path, newPath)
        
        return super.visit(newNode)
    }
}
