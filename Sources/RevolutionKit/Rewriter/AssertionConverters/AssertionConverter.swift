import Foundation
import SwiftSyntax

protocol AssertionConverter: Sendable {
    /// The assertion function name in XCTest
    var xcTestAssertionName: String { get }
    
    /// Build expr of new assertion call
    func buildExpr(from node: FunctionCallExprSyntax) -> (any ExprSyntaxProtocol)?
    
    /// Build arguments expr of new assertion call
    func arguments(from node: FunctionCallExprSyntax) -> LabeledExprListSyntax?
    
    /// Convert original arguments to for the new assertion call
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax
    
    /// Convert remaining arguments
    func convertRemainingArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax
}

extension AssertionConverter {
    func arguments(from node: FunctionCallExprSyntax) -> LabeledExprListSyntax? {
        let convertedArguments = convertAssertionArguments(of: node.arguments)
        let arguments = convertRemainingArguments(of: convertedArguments)
        
        return arguments
    }
}

protocol MacroAssertionConverter: AssertionConverter {
    var macroName: String { get }
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
    
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        // Do not convert any arguments in default
        arguments
    }
    
    func convertRemainingArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        var mutableArguments = arguments
        
        return packToSourceLocation(
            in: &mutableArguments
        )
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
    
    /// Trims the argument with the given label from the arguments list if it's found.
    /// It returns the trimmed argument if found, otherwise nil.
    /// The passed arguments list will be modified.
    private func trimArgument(of label: String, from arguments: inout LabeledExprListSyntax) -> LabeledExprSyntax? {
        guard let index = arguments.findIndex(where: { $0.label?.tokenKind == .identifier(label) }) else {
            return nil
        }
        return arguments.remove(at: index)
    }
}

protocol SingleArgumentConverter: MacroAssertionConverter { }

extension SingleArgumentConverter {
    func convertAssertionArguments(of arguments: LabeledExprListSyntax) -> LabeledExprListSyntax {
        return arguments
    }
}

protocol ExpectConverter: MacroAssertionConverter { }

extension ExpectConverter {
    var macroName: String { "expect" }
}
