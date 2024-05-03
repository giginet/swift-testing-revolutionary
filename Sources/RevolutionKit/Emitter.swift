import Foundation
import SwiftSyntax

protocol Emitter {
    associatedtype EmitType
    
    func emit(_ syntax: Syntax) -> EmitType
}

struct StringEmitter: Emitter {
    typealias EmitType = String
    
    func emit(_ syntax: Syntax) -> EmitType {
        String(bytes: syntax.syntaxTextBytes, encoding: .utf8) ?? ""
    }
}
