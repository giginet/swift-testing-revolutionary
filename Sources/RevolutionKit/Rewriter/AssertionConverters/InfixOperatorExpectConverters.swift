import Foundation
import SwiftSyntax

/// Abstract assertion converter it converts the arguments to an infix operator
protocol InfixOperatorExpectConverter: ExpectConverter {
    associatedtype LHS: ExprSyntaxProtocol
    associatedtype RHS: ExprSyntaxProtocol
    
    var binaryOperator: String { get }
    
    /// The number of arguments of the original call for building assertion
    var assertionArgumentsCount: Int { get }
    
    func lhs(from arguments: LabeledExprListSyntax) -> LHS?
    func rhs(from arguments: LabeledExprListSyntax) -> RHS?
}

extension InfixOperatorExpectConverter {
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        guard let lhs = lhs(from: arguments), let rhs = rhs(from: arguments) else {
            return arguments
        }
        
        let infixOperatorSyntax = InfixOperatorExprSyntax(
            leftOperand: lhs.with(\.trailingTrivia, .spaces(0)),
            operator: BinaryOperatorExprSyntax(
                leadingTrivia: .space,
                operator: .binaryOperator(binaryOperator),
                trailingTrivia: .space
            ),
            rightOperand: rhs.with(\.leadingTrivia, .spaces(0))
        )
        
        let hasRemainingArguments = arguments.count > assertionArgumentsCount
        
        let newArgument = LabeledExprSyntax(
            expression: infixOperatorSyntax,
            trailingComma: buildCommaToken(hasRemainingArguments: hasRemainingArguments)
        )
        
        let remainingArguments = arguments.dropFirst(assertionArgumentsCount)
        return [newArgument] + remainingArguments
    }
    
    func lhs(from arguments: LabeledExprListSyntax) -> (some ExprSyntaxProtocol)? {
        return arguments[arguments.startIndex].expression
    }
    
    func rhs(from arguments: LabeledExprListSyntax) -> (some ExprSyntaxProtocol)? {
        return arguments[arguments.index(at: 1)].expression
    }
}

struct XCTAssertEqualConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "=="
}

struct XCTAssertNotEqualConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertNotEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "!="
}

struct XCTAssertIdenticalConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertIdentical"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "==="
}

struct XCTAssertNotIdenticalConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertNotIdentical"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "!=="
}

struct XCTAssertGreaterThanConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertGreaterThan"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = ">"
}

struct XCTAssertGreaterThanOrEqualConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertGreaterThanOrEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = ">="
}

struct XCTAssertLessThanConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertLessThan"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "<"
}

struct XCTAssertLessThanOrEqualConverter: InfixOperatorExpectConverter {
    let xcTestAssertionName = "XCTAssertLessThanOrEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "<="
}

struct XCTAssertNilConverter: InfixOperatorExpectConverter {
    typealias RHS = NilLiteralExprSyntax
    let xcTestAssertionName = "XCTAssertNil"
    let assertionArgumentsCount: Int = 1
    let binaryOperator = "=="
    
    func rhs(from arguments: LabeledExprListSyntax) -> RHS? {
        NilLiteralExprSyntax()
    }
}

struct XCTAssertNotNilConverter: InfixOperatorExpectConverter {
    typealias RHS = NilLiteralExprSyntax
    let xcTestAssertionName = "XCTAssertNotNil"
    let assertionArgumentsCount: Int = 1
    let binaryOperator = "!="
    
    func rhs(from arguments: LabeledExprListSyntax) -> RHS? {
        NilLiteralExprSyntax()
    }
}
