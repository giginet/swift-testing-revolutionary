import Foundation
import SwiftSyntax

/// Rewriter to rewrite test XCTestCase class into swift-testing struct
extension TestSourceFileRewriter {
    func visitForTestClass(_ node: ClassDeclSyntax) -> DeclSyntax {
        guard guessWhetherTestCaseClass(node) else {
            return super.visit(node)
        }
        
        if shouldConvertToStruct {
            return buildStruct(from: node)
        } else {
            return buildSwiftTestingClass(from: node)
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
            .with(\.classKeyword, .keyword(.struct, leadingTrivia: node.leadingTrivia, trailingTrivia: .spaces(1)))
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
