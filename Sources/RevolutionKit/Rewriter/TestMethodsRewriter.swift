import Foundation
import SwiftSyntax

/// Rewriter to rewrite XCTest's test methods to swift-testing.
final class TestMethodsRewriter: SyntaxRewriter {
    let globalOptions: GlobalOptions
    
    init(globalOptions: GlobalOptions) {
        self.globalOptions = globalOptions
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        guard let methodKind = detectMethodKind(of: node) else {
            return DeclSyntax(node)
        }
        
        switch methodKind {
        case .testCase:
            return rewriteTestCase(node: node)
        case .setUp:
            return DeclSyntax(node)
        case .tearDown:
            return DeclSyntax(node)
        }
    }
    
    private func rewriteTestCase(node: FunctionDeclSyntax) -> DeclSyntax {
        let testCaseName = node.name.text
        let newTestCaseName = if globalOptions.enableStrippingTestPrefix {
            stripTestPrefix(of: testCaseName)
        } else {
            testCaseName
        }
        
        let testMacroAttribute = AttributeSyntax(
            attributeName: IdentifierTypeSyntax(
                name: .identifier("Test"),
                trailingTrivia: .space
            )
        )
        
        let attributes = {
            var attributes = AttributeListSyntax()
            attributes.append(.attribute(testMacroAttribute))
            return attributes
        }()
        
        let newSigniture = node
            .with(\.attributes, attributes)
            .with(\.name, .identifier(newTestCaseName))
        
        return DeclSyntax(newSigniture)
    }
    
    /// Strip first `test` prefix from test case names.
    /// `testCamelCase` -> `camelCase`
    /// `test` -> `test`
    private func stripTestPrefix(of testCaseName: String) -> String {
        precondition(testCaseName.hasPrefix("test"))
        
        return {
            var convertedName = testCaseName
            convertedName.removeFirst(4)
            
            guard let firstCharacter = convertedName.first else {
                return testCaseName
            }
            
            return firstCharacter.lowercased() + convertedName.dropFirst()
        }()
    }
    
    private func detectMethodKind(of node: FunctionDeclSyntax) -> MethodKind? {
        guard !isStaticMethod(node: node) else { return nil }
        
        return switch node.name {
        case let name where name.text.hasPrefix("test"):
                .testCase(name.text)
        case let name where name.text == "setUp":
                .setUp
        case let name where name.text == "tearDown":
                .tearDown
        default:
            nil
        }
    }
    
    private func isStaticMethod(node: FunctionDeclSyntax) -> Bool {
        node.modifiers.contains {
            $0.tokens(viewMode: .sourceAccurate).contains { $0.tokenKind == .keyword(.static) }
        }
    }
}

extension TestMethodsRewriter {
    fileprivate enum MethodKind {
        case testCase(String)
        case setUp
        case tearDown
    }
}
