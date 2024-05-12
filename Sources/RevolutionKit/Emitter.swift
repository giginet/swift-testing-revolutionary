import Foundation
import SwiftSyntax

package protocol Emitter {
    associatedtype EmitType
    
    func emit(_ syntax: Syntax) -> EmitType
}

struct StringEmitter: Emitter {
    typealias EmitType = String
    
    func emit(_ syntax: Syntax) -> EmitType {
        String(bytes: syntax.syntaxTextBytes, encoding: .utf8) ?? ""
    }
}

struct StandardOutputEmitter: Emitter {
    typealias EmitType = Void
    
    func emit(_ syntax: Syntax) -> Void {
        guard let result = String(bytes: syntax.syntaxTextBytes, encoding: .utf8) else {
            return
        }
        print(result)
    }
}
