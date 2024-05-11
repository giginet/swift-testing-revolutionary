import Foundation
import SwiftSyntax

protocol SingleArgumentExpectConverter: SingleArgumentConverter, ExpectConverter { }

struct XCTAssertConverter: SingleArgumentExpectConverter {
    let xcTestAssertionName = "XCTAssert"
}

struct XCTAssertTrueConverter: SingleArgumentExpectConverter {
    let xcTestAssertionName = "XCTAssertTrue"
}

struct XCTAssertFalseConverter: SingleArgumentExpectConverter {
    let xcTestAssertionName = "XCTAssertFalse"
    
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
