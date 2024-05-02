import Foundation
import SwiftSyntax

protocol AssertionConverter {
    var name: String { get }
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax?
}

struct XCTAssertConverter: AssertionConverter {
    let name = "XCTAssert"
    
    func argument(from node: FunctionCallExprSyntax) -> LabeledExprSyntax? {
        guard let firstArgument = node.arguments.first else {
            return nil
        }
        
        return firstArgument
    }
}
