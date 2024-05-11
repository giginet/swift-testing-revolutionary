import Foundation
import SwiftSyntax

struct XCTFailConverter: AssertionConverter {
    let xcTestAssertionName = "XCTFail"
    
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        let newCallExpr = MemberAccessExprSyntax(
            leadingTrivia: node.calledExpression.leadingTrivia,
            base: DeclReferenceExprSyntax(baseName: .identifier("Issue")),
            name: .identifier("record"),
            trailingTrivia: node.calledExpression.trailingTrivia
        ) // Issue.record
        
        return node
            .with(\.calledExpression, ExprSyntax(newCallExpr))
    }
    
    func convertAssertionArguments(of arguments: SwiftSyntax.LabeledExprListSyntax) -> SwiftSyntax.LabeledExprListSyntax {
        arguments
    }
    
    func convertRemainingArguments(of arguments: SwiftSyntax.LabeledExprListSyntax) -> SwiftSyntax.LabeledExprListSyntax {
        arguments
    }
}
