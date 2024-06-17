import Foundation
import SwiftSyntax

/// Visitor to rewrite test XCTestCase class into swift-testing struct
extension XCTestRewriter {
    func visitForTestClass(_ node: ClassDeclSyntax) -> DeclSyntax {
        guard guessWhetherTestCaseClass(node) else {
            return super.visit(node)
        }
        
        let newNode: ClassDeclSyntax
        if globalOptions.enableAddingSuite {
            let suiteAttribute = AttributeSyntax(
                attributeName: IdentifierTypeSyntax(
                    name: .identifier("Suite")
                ),
                trailingTrivia: .space
            )
            
            let newAttributes = {
                var attributes = node.attributes
                attributes.insert(.attribute(suiteAttribute), at: node.attributes.startIndex)
                return attributes
            }()
            
            newNode = node
                .with(\.attributes,
                       newAttributes
                    .with(\.leadingTrivia, node.leadingTrivia)
                )
        } else {
            newNode = node
        }
        
        if shouldConvertToStruct {
            return buildStruct(from: newNode)
        } else {
            return buildSwiftTestingClass(from: newNode)
        }
    }
    
    /// Build class decl removing inheritance of XCTestCase
    private func buildSwiftTestingClass(from node: ClassDeclSyntax) -> DeclSyntax {
        let newNode = node
            .with(\.inheritanceClause, InheritanceClauseSyntax(
                colon: .unknown(""),
                inheritedTypes: [],
                trailingTrivia: .spaces(1))
            )
        return super.visit(newNode)
    }
    
    /// Build struct decl from ClassDeclSyntax
    /// Note: It doesn't return StructDeclSyntax
    private func buildStruct(from node: ClassDeclSyntax) -> DeclSyntax {
        // We can't convert ClassDecl to StructDecl, so we just replace some parameters instead.
        let newNode = node
            .with(\.classKeyword, .keyword(
                .struct,
                leadingTrivia: node.classKeyword.leadingTrivia, 
                trailingTrivia: .space)
            )
            .with(\.modifiers, []) // get rid of 'final' keyword
            .with(\.inheritanceClause, InheritanceClauseSyntax(
                colon: .unknown(""),
                inheritedTypes: [],
                trailingTrivia: .spaces(1))
            )
        return super.visit(newNode)
    }
    
    private var shouldConvertToStruct: Bool {
        return globalOptions.enableStructConversion
    }
    
    /// Guess the passed ClassDecl would be TestCase class or not
    private func guessWhetherTestCaseClass(_ node: ClassDeclSyntax) -> Bool {
        guard let inheritedTypeSyntaxNode = node.traverse(kinds: [.inheritanceClause, .inheritedTypeList, .inheritedType], as: InheritedTypeSyntax.self) else {
            return false
        }
        guard let superClassNameToken = inheritedTypeSyntaxNode.firstToken(viewMode: .sourceAccurate) else {
            return false
        }
        
        // If its super-class is `XCTestCase`, it must be a test case
        if superClassNameToken.tokenKind == .identifier("XCTestCase") {
            return true
        }
        
        // Even not, if its name is ended with `Tests`, it might be a test case
        let className = node.name.text
        return className.hasSuffix("Tests") || className.hasSuffix("Test")
    }
}
