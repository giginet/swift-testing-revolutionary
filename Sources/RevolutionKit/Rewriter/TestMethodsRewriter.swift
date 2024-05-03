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
            return rewriteSetUp(node: node)
        case .tearDown:
            return rewriteTearDown(node: node)
        }
    }
    
    /// Rewrite XCTest test case methods to swift-testing
    /// func testExample() -> @Test func example()
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
            var attributes = node.attributes
            attributes.insert(.attribute(testMacroAttribute), at: attributes.startIndex)
            return attributes
        }()
        
        let newSigniture = node
            .with(\.attributes, attributes)
            .with(\.name, .identifier(newTestCaseName))
        
        return DeclSyntax(newSigniture)
    }
    
    /// Rewrite XCTest setUp methods to initializers
    /// func setUp() -> init()
    /// func setUpWithError() -> init() throws
    private func rewriteSetUp(node: FunctionDeclSyntax) -> DeclSyntax {
        let shouldAddThrows = node.name.text == "setUpWithError"
        
        // If the method was `setUpWithError`, add `throws` as a function effect specifier
        let effectSpecifiers: FunctionEffectSpecifiersSyntax?
        if shouldAddThrows {
            let emptyEffectSpecifiers = FunctionEffectSpecifiersSyntax()
            effectSpecifiers = emptyEffectSpecifiers
                .with(
                    \.throwsSpecifier, .keyword(.throws)
                )
                .with(\.trailingTrivia, .space)
        } else {
            effectSpecifiers = node.signature.effectSpecifiers
        }
        
        let initializerDecl = InitializerDeclSyntax(
            leadingTrivia: node.leadingTrivia,
            attributes: node.attributes,
            modifiers: node.modifiers,
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax(),
                    trailingTrivia: .space
                ),
                effectSpecifiers: effectSpecifiers
            ),
            body: node.body,
            trailingTrivia: node.trailingTrivia
        )
        
        return DeclSyntax(initializerDecl)
    }
    
    /// Rewrite XCTest tearDown methods to destructors
    private func rewriteTearDown(node: FunctionDeclSyntax) -> DeclSyntax {
        precondition(node.name.text == "tearDown")
        
        // TODO: If tearDown method has any function effect specifiers,
        // warn about this because it might not be compiled
        
        let deinitializerDecl = DeinitializerDeclSyntax(
            leadingTrivia: node.leadingTrivia,
            attributes: node.attributes,
            modifiers: node.modifiers,
            body: node.body?.with(\.leadingTrivia, .space),
            trailingTrivia: node.trailingTrivia
        )
        
        return DeclSyntax(deinitializerDecl)
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
    
    /// Returns a kind of the method
    private func detectMethodKind(of node: FunctionDeclSyntax) -> MethodKind? {
        guard !isStaticMethod(node: node) else { return nil }
        
        return switch node.name.text {
        case let name where name.hasPrefix("test"):
                .testCase(name)
        case let name where ["setUp", "setUpWithError"].contains(name):
                .setUp
        case let name where ["tearDown"].contains(name):
            // We can't support `tearDownWithError` because the destructors can't throw any errors.
                .tearDown
        default:
            nil
        }
    }
    
    /// Returns true if the method is static
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