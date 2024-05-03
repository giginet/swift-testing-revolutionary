import Foundation
import SwiftSyntax

/// Rewriter for the whole test file. It expects to be used for SourceFileSyntax
class XCTestRewriter: SyntaxRewriter {
    let globalOptions: GlobalOptions
    
    init(globalOptions: GlobalOptions) {
        self.globalOptions = globalOptions
    }
    
    override func visit(_ node: ImportDeclSyntax) -> DeclSyntax {
        visitForImportDecl(node)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        visitForTestClass(node)
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        visitForTestFunctionDecl(node)
    }
//
//    override func visit(_ node: TryExprSyntax) -> ExprSyntax {
//        super.visit(node)
//    }
//    
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        visitForTestFunctionCall(node)
    }
}
