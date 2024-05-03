import Foundation
import SwiftSyntax

private let xcTestAssertionConverters: [any AssertionConverter] = [
    XCTAssertConverter(),
    XCTAssertTrueConverter(),
    XCTAssertFalseConverter(),
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
    XCTUnwrapConverter(),
    XCTFailConverter(),
    XCTAssertNoThrowConverter(),
]

/// Rewriter to replace XCTest assertions to swift-testing.
extension TestSourceFileRewriter {
    func visitForTestFunctionCall(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        let converter = node.calledExpression.tokens(viewMode: .sourceAccurate).compactMap { token in
            xcTestAssertionConverters.find(by: token.text)
        }.first
        guard let converter else { return super.visit(node) }
        
        guard let existentialExpr = converter.buildExpr(from: node) else { return super.visit(node) }
        
        return super.visit(ExprSyntax(existentialExpr))
    }
}

extension [any AssertionConverter] {
    fileprivate func find(by name: String) -> Element? {
        first { converter in
            converter.name == name
        }
    }
}
