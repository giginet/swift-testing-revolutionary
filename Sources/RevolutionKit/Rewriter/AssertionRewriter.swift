import Foundation
import SwiftSyntax

private let xcTestAssertionConverters: [any AssertionConverter] = [
    XCTAssertConverter(),
    XCTAssertTrueConverter(),
    XCTAssertEqualConverter(),
    XCTAssertNotEqualConverter(),
    XCTAssertIdenticalConverter(),
    XCTAssertNotIdenticalConverter(),
    XCTAssertGreaterThanConverter(),
    XCTAssertGreaterThanOrEqualConverter(),
    XCTAssertLessThanOrEqualConverter(),
    XCTAssertLessThanConverter(),
    XCTAssertNilConverter(),
    XCTAssertNotNilConverter(),
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
        
        guard let existentialExpr = converter.buildExpr(from: node) else { return super.visit(node) }
        
        return ExprSyntax(existentialExpr)
    }
}

extension [any AssertionConverter] {
    fileprivate func find(by name: String) -> Element? {
        first { converter in
            converter.name == name
        }
    }
}
