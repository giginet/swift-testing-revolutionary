import Foundation
import SwiftSyntax

protocol AssertionConverter {
    var name: String { get }
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)?
    func arguments(from node: FunctionCallExprSyntax) -> LabeledExprListSyntax?
}

protocol MacroAssertionConverter: AssertionConverter {
    var macroName: String { get }
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax
}

extension MacroAssertionConverter {
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        guard let arguments = arguments(from: node) else {
            return nil
        }
        
        return MacroExpansionExprSyntax(
            leadingTrivia: node.leadingTrivia,
            macroName: .identifier(macroName),
            leftParen: node.leftParen,
            arguments: arguments,
            rightParen: node.rightParen,
            trailingTrivia: node.trailingTrivia
        )
    }
}

extension MacroAssertionConverter {
    func arguments(from node: FunctionCallExprSyntax) -> LabeledExprListSyntax? {
        let convertedArguments = convertAssertionArguments(of: node.arguments)
        let arguments = convertRemainingArguments(of: convertedArguments)
        
        return arguments
    }
    
    func convertRemainingArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        var mutableArguments = arguments
        
        return packToSourceLocation(
            in: &mutableArguments
        )
    }
    
    /// Trims the argument with the given label from the arguments list if it's found.
    /// It returns the trimmed argument if found, otherwise nil.
    /// The passed arguments list will be modified.
    private func trimArgument(of label: String, from arguments: inout LabeledExprListSyntax) -> LabeledExprSyntax? {
        guard let index = arguments.findIndex(where: { $0.label?.tokenKind == .identifier(label) }) else {
            return nil
        }
        return arguments.remove(at: index)
    }
    
    /// Pack file/line arguments in the given arguments into SourceLocation arguments
    /// Example (file: "XXX", line: 999) -> (sourceLocation: SourceLocation(file: "XXX", line: 999))
    fileprivate func packToSourceLocation(in arguments: inout LabeledExprListSyntax) -> LabeledExprListSyntax {
        let fileArgument = trimArgument(of: "file", from: &arguments)
        let lineArgument = trimArgument(of: "line", from: &arguments)
        
        guard (fileArgument != nil || lineArgument != nil) else {
            return arguments
        }
        
        var sourceLocationArguments = LabeledExprListSyntax()
        if let fileArgument {
            sourceLocationArguments.append(fileArgument)
        }
        
        if let lineArgument {
            sourceLocationArguments.append(lineArgument)
        }
        
        let sourceLocationReferenceExpr = DeclReferenceExprSyntax(
            baseName: .identifier("SourceLocation")
        ) // SourceLocation
        
        let sourceLocationInitializerCallExpr = FunctionCallExprSyntax(
            calledExpression: sourceLocationReferenceExpr,
            leftParen: .leftParenToken(),
            arguments: sourceLocationArguments,
            rightParen: .rightParenToken()
        ) // SourceLocation(file: "XXX", line: 999)
        
        let fileLocationArgumentExpr = LabeledExprSyntax(
            label: .identifier("sourceLocation"),
            colon: .colonToken(trailingTrivia: .space),
            expression: sourceLocationInitializerCallExpr
        ) // sourceLocation: SourceLocation()
        
        return arguments + [fileLocationArgumentExpr]
    }
}

protocol SingleArgumentConverter: MacroAssertionConverter {
}

extension SingleArgumentConverter {
    var requiredArguments: Int { 1 }
    
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        return arguments
    }
}

protocol ExpectConverter: MacroAssertionConverter { }

extension ExpectConverter {
    var macroName: String { "expect" }
}

protocol SingleArgumentExpectConverter: SingleArgumentConverter, ExpectConverter {
}


struct XCTAssertConverter: SingleArgumentExpectConverter {
    let name = "XCTAssert"
}

struct XCTAssertTrueConverter: SingleArgumentExpectConverter {
    let name = "XCTAssertTrue"
}

struct XCTAssertFalseConverter: SingleArgumentExpectConverter {
    let name = "XCTAssertFalse"
    
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        guard let firstArgument = arguments.first else {
            return arguments
        }
        let inverted = PrefixOperatorExprSyntax(
            operator: .exclamationMarkToken(),
            expression: firstArgument.expression
        ) // !argument
        let newFirstArgument = firstArgument
            .with(\.expression, ExprSyntax(inverted))
        
        let firstIndex = arguments.startIndex
        return arguments.with(\.[firstIndex], newFirstArgument)
    }
}

// MARK: BinaryOperatorExpectConverter

/// Abstract assertion converter it converts the arguments to an infix operator
protocol InfixOperatorExpectConverter: ExpectConverter {
    associatedtype LHS: ExprSyntaxProtocol
    associatedtype RHS: ExprSyntaxProtocol
    
    var binaryOperator: String { get }
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
        
        // Drop lhs and rhs
        let hasRemainingArguments = arguments.count > assertionArgumentsCount
        
        // If remaining arguments are exists, comma is required
        let trailingComma: TokenSyntax? = if hasRemainingArguments {
            .commaToken(trailingTrivia: .space)
        } else {
            nil
        }
        
        let newArgument = LabeledExprSyntax(
            expression: infixOperatorSyntax,
            trailingComma: trailingComma
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
    let name = "XCTAssertEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "=="
}

struct XCTAssertNotEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertNotEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "!="
}

struct XCTAssertIdenticalConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertIdentical"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "==="
}

struct XCTAssertNotIdenticalConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertNotIdentical"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "!=="
}

struct XCTAssertGreaterThanConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertGreaterThan"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = ">"
}

struct XCTAssertGreaterThanOrEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertGreaterThanOrEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = ">="
}

struct XCTAssertLessThanConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertLessThan"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "<"
}

struct XCTAssertLessThanOrEqualConverter: InfixOperatorExpectConverter {
    let name = "XCTAssertLessThanOrEqual"
    let assertionArgumentsCount: Int = 2
    let binaryOperator = "<="
}

struct XCTAssertNilConverter: InfixOperatorExpectConverter {
    typealias RHS = NilLiteralExprSyntax
    let name = "XCTAssertNil"
    let assertionArgumentsCount: Int = 1
    let binaryOperator = "=="
    
    func rhs(from arguments: LabeledExprListSyntax) -> RHS? {
        NilLiteralExprSyntax()
    }
}

struct XCTAssertNotNilConverter: InfixOperatorExpectConverter {
    typealias RHS = NilLiteralExprSyntax
    let name = "XCTAssertNotNil"
    let assertionArgumentsCount: Int = 1
    let binaryOperator = "!="
    
    func rhs(from arguments: LabeledExprListSyntax) -> RHS? {
        NilLiteralExprSyntax()
    }
}

// MARK: RequireConverter

protocol RequireConverter: MacroAssertionConverter {
}

extension RequireConverter {
    var macroName: String { "require" }
}

struct XCTUnwrapConverter: SingleArgumentConverter, RequireConverter {
    let name = "XCTUnwrap"
}

// MARK: XCTFail

struct XCTFailConverter: AssertionConverter {
    let name = "XCTFail"
    
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
    
    func arguments(from node: FunctionCallExprSyntax) -> LabeledExprListSyntax? {
        return node.arguments
            .replacing(with: [node.arguments.first].compactMap { $0 })
    }
}

// MARK: XCTAssertThrowsError / XCTAssertNoThrow

protocol ErrorAssertionExpectConverter: MacroAssertionConverter, ExpectConverter {
    func trailingClosure(from node: FunctionCallExprSyntax) -> ClosureExprSyntax?
}

extension ErrorAssertionExpectConverter {
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        // FIXME
        return arguments
    }
    
    fileprivate func convertArgumentsToClosure(of node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
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
    
    /// Build `#expect` macro which has trailing closure it calls the previous argument
    /// functionName(args) -> functionName(arguments) { args }
    fileprivate func buildExpectMacroMovingArgumentsToTrailingClosure(node: FunctionCallExprSyntax) -> MacroExpansionExprSyntax? {
        guard let arguments = arguments(from: node), let trailingClosure = trailingClosure(from: node) else {
            return nil
        }
        
        return MacroExpansionExprSyntax(
            macroName: .identifier("expect"),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken(),
            trailingClosure: trailingClosure
        )
    }
}

struct XCTAssertThrowsErrorConverter: ErrorAssertionExpectConverter {
    let name = "XCTAssertThrowsError"
    let macroName = "expect"
    
    /// Model to represent expect macro variants
    /// swift-testing has two `#expect` macros for error handlings.
    private enum ExpectMacroType {
        /// expect macro to check error type
        /// https://swiftpackageindex.com/apple/swift-testing/main/documentation/testing/expect(throws:_:sourcelocation:performing:)-79piu
        case typeChecking
        
        /// expect macro to check error conditions
        /// https://swiftpackageindex.com/apple/swift-testing/main/documentation/testing/expect(_:sourcelocation:performing:throws:)
        case conditionChecking
    }
    
    private func expectMacroType(of node: FunctionCallExprSyntax) -> ExpectMacroType {
        if node.trailingClosure != nil {
            return .conditionChecking
        } else {
            return .typeChecking
        }
    }
    
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        switch expectMacroType(of: node) {
        case .conditionChecking:
            return buildCheckingErrorConditionExpectMacro(node: node)
        case .typeChecking:
            return buildErrorTypeCheckingExpectMacro(node: node)
        }
    }
    
    func arguments(from node: FunctionCallExprSyntax) -> LabeledExprListSyntax? {
        switch expectMacroType(of: node) {
        case .conditionChecking:
            return buildArgumentsForConditionCheckingMacro(node: node)
        case .typeChecking:
            return buildArgumentsForTypeCheckingMacro(node: node)
        }
    }
    
    func trailingClosure(from node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
        switch expectMacroType(of: node) {
        case .conditionChecking:
            fatalError("Do not call this function for conditional checking")
        case .typeChecking:
            return buildTrailingClosureForTypeCheckingMacro(node: node)
        }
    }
    
    /// Build #expect macro node to check Error type.
    /// It would be called when the original node doesn't have any trailing closures.
    private func buildErrorTypeCheckingExpectMacro(node: FunctionCallExprSyntax) -> MacroExpansionExprSyntax? {
        buildExpectMacroMovingArgumentsToTrailingClosure(node: node)
    }
    
    private func buildArgumentsForTypeCheckingMacro(node: FunctionCallExprSyntax) -> LabeledExprListSyntax {
        let anyErrorSyntax = TypeExprSyntax(type: SomeOrAnyTypeSyntax(
            someOrAnySpecifier: .keyword(.any, trailingTrivia: .space),
            constraint: IdentifierTypeSyntax(name: .identifier("Error"))
        )) // any Error
        
        let anyErrorDotSelfExpr = MemberAccessExprSyntax(
            base: TupleExprSyntax(
                elements: LabeledExprListSyntax([
                    LabeledExprSyntax(expression: anyErrorSyntax)
                ])
            ),
            name: .keyword(.self)
        ) // (any Error).self
        
        let newArgument = LabeledExprSyntax(
            label: .identifier("throws"),
            colon: .colonToken(trailingTrivia: .space),
            expression: anyErrorDotSelfExpr
        ) // throws: (any Error).self
        
        return node.arguments
            .replacing(with: [newArgument].compactMap { $0 })
    }
    
    private func buildTrailingClosureForTypeCheckingMacro(node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
        convertArgumentsToClosure(of: node)
    }
    
    /// Build #expect macro node to check Error conditions.
    /// It would be called when the original node has a trailing closure.
    private func buildCheckingErrorConditionExpectMacro(node: FunctionCallExprSyntax) -> MacroExpansionExprSyntax? {
        guard let arguments = arguments(from: node) else {
            return nil
        }
        
        guard let performingTrailingClosure = buildPerformingTrailingClosureForConditionCheckingMacro(node: node),
              let throwsTrailingClosure = buildThrowsTrailingClosureForConditionCheckingMacro(node: node) else {
            return nil
        }
        
        let expectLabeledTrailingClosure = MultipleTrailingClosureElementSyntax(
            label: .identifier("throws"),
            colon: .colonToken(trailingTrivia: .space),
            closure: throwsTrailingClosure
        ) // throws: { ... }
        
        var additionalTrailingClosures = node.additionalTrailingClosures
        additionalTrailingClosures.append(expectLabeledTrailingClosure)
        
        return MacroExpansionExprSyntax(
            macroName: .identifier("expect"),
            leftParen: arguments.isEmpty ? nil : .leftParenToken(),
            arguments: arguments,
            rightParen: arguments.isEmpty ? nil : .rightParenToken(),
            trailingClosure: performingTrailingClosure
                .with(\.leadingTrivia, .space)
                .with(\.trailingTrivia, .space),
            additionalTrailingClosures: additionalTrailingClosures
        ) // #expect { ... } throws: { ... }
    }
    
    private func buildArgumentsForConditionCheckingMacro(node: FunctionCallExprSyntax) -> LabeledExprListSyntax? {
        // the first argument will move to the first trailing closure. So remaining arguments will be new arguments
        var arguments = node.arguments
        arguments.remove(at: arguments.startIndex)
        return arguments
    }
    
    private func buildPerformingTrailingClosureForConditionCheckingMacro(node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
        convertArgumentsToClosure(of: node)
    }
    
    private func buildThrowsTrailingClosureForConditionCheckingMacro(node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
        node.trailingClosure
    }
}

struct XCTAssertNoThrowConverter: ErrorAssertionExpectConverter {
    let name = "XCTAssertNoThrow"
    let macroName = "expect"
    
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        buildExpectMacroMovingArgumentsToTrailingClosure(node: node)
    }
    
    func arguments(from node: FunctionCallExprSyntax) -> LabeledExprListSyntax? {
        let neverError = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier("Never")),
            name: .keyword(.self)
        ) // Never.self
        let newArgument = LabeledExprSyntax(
            label: .identifier("throws"),
            colon: .colonToken(trailingTrivia: .space),
            expression: neverError
        ) // throws: Never.self
        
        return node.arguments
            .replacing(with: [newArgument])
    }
    
    func trailingClosure(from node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
        convertArgumentsToClosure(of: node)
    }
}
