import Foundation
import SwiftSyntax

protocol ErrorAssertionExpectConverter: MacroAssertionConverter, ExpectConverter {
    func trailingClosure(from node: FunctionCallExprSyntax) -> ClosureExprSyntax?
    func additionalTrailingClosures(from node: FunctionCallExprSyntax) -> MultipleTrailingClosureElementListSyntax?
}

extension ErrorAssertionExpectConverter {
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)? {
        guard let arguments = arguments(from: node), var trailingClosure = trailingClosure(from: node) else {
            return nil
        }
        
        let additionalTrailingClosures = additionalTrailingClosures(from: node)
        
        trailingClosure = trailingClosure
            .with(\.leadingTrivia, .space)
        if additionalTrailingClosures != nil {
            trailingClosure = trailingClosure
                .with(\.trailingTrivia, .space)
        }
        
        return MacroExpansionExprSyntax(
            macroName: .identifier("expect"),
            leftParen: arguments.isEmpty ? nil : .leftParenToken(),
            arguments: arguments,
            rightParen: arguments.isEmpty ? nil : .rightParenToken(),
            trailingClosure: trailingClosure,
            additionalTrailingClosures: additionalTrailingClosures ?? []
        ) // #expect { ... } throws: { ... }
    }
    
    func trailingClosure(from node: FunctionCallExprSyntax) -> ClosureExprSyntax? {
        // The first argument will be trailing closure
        guard let closureCall = node.arguments.first else {
            return nil
        }
        
        let codeBlockItems = CodeBlockItemListSyntax([
            CodeBlockItemSyntax(
                leadingTrivia: .space,
                item: .expr(closureCall.expression),
                trailingTrivia: .space
            )
        ]) //{ ... }
        return ClosureExprSyntax(
            leadingTrivia: .space,
            statements: codeBlockItems
        ) // { ... }
    }
    
    func additionalTrailingClosures(from node: FunctionCallExprSyntax) -> MultipleTrailingClosureElementListSyntax? {
        return nil
    }
}

struct XCTAssertThrowsErrorConverter: ErrorAssertionExpectConverter {
    let xcTestAssertionName = "XCTAssertThrowsError"
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
    
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        // FIXME up-casting is required...
        guard let node = arguments.parent?.cast(FunctionCallExprSyntax.self) else {
            return arguments
        }
        let macroType = expectMacroType(of: node)
        switch macroType {
        case .typeChecking:
            return buildArgumentsForTypeCheckingMacro(node: node)
        case .conditionChecking:
            return LabeledExprListSyntax(arguments.dropFirst())
        }
    }
}

extension XCTAssertThrowsErrorConverter {
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
        
        let hasRemainingArguments = node.arguments.count > 1
        
        let newArgument = LabeledExprSyntax(
            label: .identifier("throws"),
            colon: .colonToken(trailingTrivia: .space),
            expression: anyErrorDotSelfExpr,
            trailingComma: buildCommaToken(hasRemainingArguments: hasRemainingArguments)
        ) // throws: (any Error).self
        
        return node.arguments
            .with(\.[node.arguments.startIndex], newArgument)
    }
}

extension XCTAssertThrowsErrorConverter {
    func additionalTrailingClosures(from node: FunctionCallExprSyntax) -> MultipleTrailingClosureElementListSyntax? {
        guard let throwsTrailingClosure = node.trailingClosure else {
            return nil
        }
        
        let expectLabeledTrailingClosure = MultipleTrailingClosureElementSyntax(
            label: .identifier("throws"),
            colon: .colonToken(trailingTrivia: .space),
            closure: throwsTrailingClosure
        ) // throws: { ... }
        
        var additionalTrailingClosures = node.additionalTrailingClosures
        additionalTrailingClosures.append(expectLabeledTrailingClosure)
        return additionalTrailingClosures
    }
}

struct XCTAssertNoThrowConverter: ErrorAssertionExpectConverter {
    let xcTestAssertionName = "XCTAssertNoThrow"
    
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        let neverError = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier("Never")),
            name: .keyword(.self)
        ) // Never.self
        
        let hasRemainingArguments = arguments.count > 1
        
        let newArgument = LabeledExprSyntax(
            label: .identifier("throws"),
            colon: .colonToken(trailingTrivia: .space),
            expression: neverError,
            trailingComma: buildCommaToken(hasRemainingArguments: hasRemainingArguments)
        ) // throws: Never.self
        
        return arguments
            .with(\.[arguments.startIndex], newArgument)
    }
}

extension AssertionConverter {
    func buildCommaToken(hasRemainingArguments: Bool) -> TokenSyntax? {
        if hasRemainingArguments {
            .commaToken(trailingTrivia: .space)
        } else {
            nil
        }
    }
}
