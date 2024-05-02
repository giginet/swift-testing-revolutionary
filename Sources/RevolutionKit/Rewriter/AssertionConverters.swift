import Foundation
import SwiftSyntax

protocol AssertionConverter {
    var name: String { get }
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)?
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax?
}

protocol ExpectConverter: AssertionConverter { }

extension ExpectConverter {
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        guard let argument = argument(from: node) else {
            return nil
        }
        var arguments = LabeledExprListSyntax()
        arguments.append(argument)
        
        return MacroExpansionExprSyntax(
            macroName: .identifier("expect"),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken()
        )
    }
}

struct XCTAssertConverter: ExpectConverter {
    let name = "XCTAssert"
    
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        return node.arguments.first
    }
}

struct XCTAssertTrueConverter: ExpectConverter {
    let name = "XCTAssertTrue"
    
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        return node.arguments.first
    }
}
