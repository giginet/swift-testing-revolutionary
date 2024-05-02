import Foundation
import SwiftSyntax

private let xcTestAssertionConverters: [any AssertionConverter] = [
    XCTAssertConverter(),
]


/// Rewriter to replace XCTest assertions to swift-testing.
final class AssertionRewriter: SyntaxRewriter {
    private let globalOptions: GlobalOptions
    
    init(globalOptions: GlobalOptions) {
        self.globalOptions = globalOptions
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let converter = node.calledExpression.tokens(viewMode: .sourceAccurate).compactMap { token in
            xcTestAssertionConverters.find(by: token.text)
        }.first
        guard let converter else { return super.visit(node) }
        
        guard let argument = converter.argument(from: node) else { return super.visit(node) }
        
        let macroExpansionExpr = buildExpectMacro(argument: argument)
        
        return ExprSyntax(macroExpansionExpr)
    }
    
    private func buildExpectMacro(argument: LabeledExprSyntax) -> MacroExpansionExprSyntax {
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

extension [any AssertionConverter] {
    fileprivate func find(by name: String) -> Element? {
        first { converter in
            converter.name == name
        }
    }
}
