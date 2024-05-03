import Foundation
import SwiftSyntax

/// Visitor to replace `XCTest` imports with `Testing`.
extension XCTestRewriter {
    func visitForImportDecl(_ node: ImportDeclSyntax) -> DeclSyntax {
        guard let importPathComponentList = node.first(of: .importPathComponentList, as: ImportPathComponentListSyntax.self),
              let importPathComponent = importPathComponentList.first(of: .importPathComponent, as: ImportPathComponentSyntax.self),
              importPathComponent.name.tokenKind == .identifier("XCTest")
        else {
            return super.visit(node)
        }
        
        let newPath = importPathComponent
            .with(\.name, .identifier("Testing"))
        
        let newPathList = importPathComponentList
            .with(\.[importPathComponentList.startIndex], newPath)
        
        let newNode = node
            .with(\.path, newPathList)
        
        return super.visit(newNode)
    }
}
