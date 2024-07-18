import Foundation
import SwiftSyntax

/// Visitor to rewrite XCTest's test methods to swift-testing.
extension XCTestRewriter {
    func visitForTestFunctionDecl(_ node: FunctionDeclSyntax) -> DeclSyntax {
        guard !node.hasTestMacroAttribute else { return super.visit(node) }
        guard let methodKind = detectMethodKind(of: node) else {
            return super.visit(node)
        }
        
        switch methodKind {
        case .testCase:
            return super.visit(rewriteTestCase(node: node))
        case .setUp:
            return super.visit(rewriteSetUp(node: node))
        case .tearDown:
            return super.visit(rewriteTearDown(node: node))
        }
    }
    
    /// Rewrite XCTest test case methods to swift-testing
    /// func testExample() -> @Test func example()
    private func rewriteTestCase(node: FunctionDeclSyntax) -> DeclSyntax {
        let testCaseName = node.name.text
        let newTestCaseName = if globalOptions.enableStrippingTestPrefix {
            strippingTestPrefix(of: testCaseName)
        } else {
            testCaseName
        }
        
        let testMacroAttribute = AttributeSyntax(
            attributeName: IdentifierTypeSyntax(
                name: .identifier("Test")
            ),
            trailingTrivia: .space
        )
        
        let attributes = {
            var attributes = node.attributes
            attributes.insert(.attribute(testMacroAttribute), at: attributes.startIndex)
            return attributes
                .with(\.leadingTrivia, node.leadingTrivia)
                .with(\.trailingTrivia, .space)
        }()
        
        let newSigniture = node
            .with(\.leadingTrivia, .spaces(0))
            .with(\.attributes, attributes)
            .with(\.name, .identifier(newTestCaseName))
        
        return DeclSyntax(newSigniture)
    }
    
    /// Rewrite XCTest setUp methods to initializers
    /// func setUp() -> init()
    /// func setUpWithError() -> init() throws
    private func rewriteSetUp(node: FunctionDeclSyntax) -> DeclSyntax {
        let effectSpecifiers = node.signature.effectSpecifiers
        
        let initializerDecl = InitializerDeclSyntax(
            leadingTrivia: node.leadingTrivia,
            attributes: node.attributes,
            modifiers: removeInvalidModifiers(from: node.modifiers),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax(),
                    trailingTrivia: .space
                ),
                effectSpecifiers: effectSpecifiers
            ),
            body: node.body
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
            modifiers: removeInvalidModifiers(from: node.modifiers),
            body: node.body?.with(\.leadingTrivia, .space)
        )
        
        return DeclSyntax(deinitializerDecl)
    }
    
    /// Strip first `test` prefix from test case names.
    /// `testCamelCase` -> `camelCase`
    /// `test` -> `test`
    private func strippingTestPrefix(of testCaseName: String) -> String {
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
    
    /// Removes some invalid modifiers for initializer/deinitializer
    /// This method trims `override` attribute
    private func removeInvalidModifiers(from modifiers: DeclModifierListSyntax) -> DeclModifierListSyntax {
        var newModifiers = modifiers
        guard let index = modifiers.findIndex(where: { $0.name.tokenKind == .keyword(.override) }) else {
            return modifiers
        }
        newModifiers.remove(at: index)
        return newModifiers
    }
}

extension XCTestRewriter {
    fileprivate enum MethodKind {
        case testCase(String)
        case setUp
        case tearDown
    }
}

extension FunctionDeclSyntax {
    fileprivate var hasTestMacroAttribute: Bool {
        attributes.contains { attribute in
            switch attribute {
            case .attribute(let attributeNode):
                let attributeName = attributeNode.attributeName.as(IdentifierTypeSyntax.self)?.name
                return attributeName?.tokenKind == .identifier("Test")
            case .ifConfigDecl: return false
            }
        }
    }
}
