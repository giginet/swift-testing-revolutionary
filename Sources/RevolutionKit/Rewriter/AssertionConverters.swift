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

// MARK: BinaryOperatorExpectConverter

/// Abstract assertion converter it converts the arguments to an infix operator
protocol InfixOperatorExpectConverter: ExpectConverter {
    associatedtype LHS: ExprSyntaxProtocol
    associatedtype RHS: ExprSyntaxProtocol
    
    var binaryOperator: String { get }
    
    func lhs(from node: FunctionCallExprSyntax) -> LHS
    func rhs(from node: FunctionCallExprSyntax) -> RHS
}

extension InfixOperatorExpectConverter {
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        guard node.arguments.count >= 2 else {
            return nil
        }
        
        let infixOperatorSyntax = InfixOperatorExprSyntax(
            leftOperand: lhs(from: node),
            operator: BinaryOperatorExprSyntax(
                leadingTrivia: .space,
                operator: .binaryOperator(binaryOperator),
                trailingTrivia: .space
            ),
            rightOperand: rhs(from: node)
        )
        return LabeledExprSyntax(expression: infixOperatorSyntax)
    }
    
    func lhs(from node: FunctionCallExprSyntax) -> some ExprSyntaxProtocol {
        return node.arguments[node.arguments.startIndex].expression
    }
    
    func rhs(from node: FunctionCallExprSyntax) -> some ExprSyntaxProtocol {
        return node.arguments[node.arguments.index(at: 1)].expression
    }
}

struct XCTAssertEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertEqual"
    let binaryOperator = "=="
}
