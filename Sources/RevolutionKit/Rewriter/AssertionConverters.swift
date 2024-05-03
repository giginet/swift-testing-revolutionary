import Foundation
import SwiftSyntax

protocol AssertionConverter {
    var name: String { get }
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)?
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax?
}

protocol MacroAssertionConverter: AssertionConverter {
    var macroName: String { get }
}

extension MacroAssertionConverter {
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        guard let argument = argument(from: node) else {
            return nil
        }
        var arguments = LabeledExprListSyntax()
        arguments.append(argument)
        
        return MacroExpansionExprSyntax(
            leadingTrivia: node.leadingTrivia,
            macroName: .identifier(macroName),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken(),
            trailingTrivia: node.trailingTrivia
        )
    }
}

protocol ExpectConverter: MacroAssertionConverter { }

extension ExpectConverter {
    var macroName: String { "expect" }
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

struct XCTAssertFalseConverter: ExpectConverter {
    let name = "XCTAssertFalse"
    
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        guard let argument = node.arguments.first else {
            return nil
        }
        let inverted = PrefixOperatorExprSyntax(
            operator: .exclamationMarkToken(),
            expression: argument.expression
        )
        return LabeledExprSyntax(expression: inverted)
    }
}

// MARK: BinaryOperatorExpectConverter

/// Abstract assertion converter it converts the arguments to an infix operator
protocol InfixOperatorExpectConverter: ExpectConverter {
    associatedtype LHS: ExprSyntaxProtocol
    associatedtype RHS: ExprSyntaxProtocol
    
    var binaryOperator: String { get }
    
    func lhs(from node: FunctionCallExprSyntax) -> LHS?
    func rhs(from node: FunctionCallExprSyntax) -> RHS?
}

extension InfixOperatorExpectConverter {
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        guard let lhs = lhs(from: node), let rhs = rhs(from: node) else {
            return nil
        }
        
        let infixOperatorSyntax = InfixOperatorExprSyntax(
            leftOperand: lhs,
            operator: BinaryOperatorExprSyntax(
                leadingTrivia: .space,
                operator: .binaryOperator(binaryOperator),
                trailingTrivia: .space
            ),
            rightOperand: rhs
        )
        return LabeledExprSyntax(expression: infixOperatorSyntax)
    }
    
    func lhs(from node: FunctionCallExprSyntax) -> (some ExprSyntaxProtocol)? {
        return node.arguments[node.arguments.startIndex].expression
    }
    
    func rhs(from node: FunctionCallExprSyntax) -> (some ExprSyntaxProtocol)? {
        return node.arguments[node.arguments.index(at: 1)].expression
    }
}

struct XCTAssertEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertEqual"
    let binaryOperator = "=="
}

struct XCTAssertNotEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertNotEqual"
    let binaryOperator = "!="
}

struct XCTAssertIdenticalConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertIdentical"
    let binaryOperator = "==="
}

struct XCTAssertNotIdenticalConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertNotIdentical"
    let binaryOperator = "!=="
}

struct XCTAssertGreaterThanConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertGreaterThan"
    let binaryOperator = ">"
}

struct XCTAssertGreaterThanOrEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertGreaterThanOrEqual"
    let binaryOperator = ">="
}

struct XCTAssertLessThanConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertLessThan"
    let binaryOperator = "<"
}

struct XCTAssertLessThanOrEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertLessThanOrEqual"
    let binaryOperator = "<="
}

struct XCTAssertNilConverter: InfixOperatorExpectConverter {
    typealias RHS = NilLiteralExprSyntax
    let name = "XCTAssertNil"
    let binaryOperator = "=="
    
    func rhs(from node: FunctionCallExprSyntax) -> RHS? {
        NilLiteralExprSyntax()
    }
}

struct XCTAssertNotNilConverter: InfixOperatorExpectConverter {
    typealias RHS = NilLiteralExprSyntax
    let name = "XCTAssertNotNil"
    let binaryOperator = "!="
    
    func rhs(from node: FunctionCallExprSyntax) -> RHS? {
        NilLiteralExprSyntax()
    }
}

// MARK: RequireConverter

protocol RequireConverter: MacroAssertionConverter {
}

extension RequireConverter {
    var macroName: String { "require" }
}

struct XCTUnwrapConverter: RequireConverter {
    let name = "XCTUnwrap"
    
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        return node.arguments.first
    }
}

// MARK: XCTFail

struct XCTFailConverter: AssertionConverter {
    let name = "XCTFail"
    
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        guard let argument = argument(from: node) else {
            return nil
        }
        var arguments = LabeledExprListSyntax()
        arguments.append(argument)
        
        return FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier("Issue")),
                name: .identifier("record")
            ),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken()
        )
    }
    
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        return node.arguments.first
    }
}

// MARK: XCTAssertThrowsError / XCTAssertNoThrow

struct XCTAssertNoThrowConverter: AssertionConverter {
    let name = "XCTAssertNoThrow"
    
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        guard let argument = argument(from: node), let trailingClosure = trailingClosure(from: node) else {
            return nil
        }
        
        let arguments = LabeledExprListSyntax([
            argument
        ])
        
        return MacroExpansionExprSyntax(
            macroName: .identifier("expect"),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken(),
            trailingClosure: trailingClosure
        )
    }
    
    func trailingClosure(from node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
        guard let closureCall = node.arguments.first else {
            return nil
        }
        
        let codeBlockItems = CodeBlockItemListSyntax([
            CodeBlockItemSyntax(
                leadingTrivia: .space,
                item: .expr(closureCall.expression),
                trailingTrivia: .space
            )
        ])
        return ClosureExprSyntax(
            leadingTrivia: .space,
            statements: codeBlockItems
        )
    }
    
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        let neverError = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier("Never")),
            name: .keyword(.self)
        )
        return LabeledExprSyntax(
            label: .identifier("throws"),
            colon: .colonToken(trailingTrivia: .space),
            expression: neverError
        )
    }
}
