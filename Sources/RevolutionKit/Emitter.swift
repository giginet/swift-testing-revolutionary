import Foundation
import SwiftSyntax

package protocol Emitter {
    associatedtype EmitType
    
    func emit(_ syntax: Syntax) throws -> EmitType
}

struct StringEmitter: Emitter {
    typealias EmitType = String
    
    func emit(_ syntax: Syntax) -> EmitType {
        String(bytes: syntax.syntaxTextBytes, encoding: .utf8) ?? ""
    }
}

struct DryRunEmitter: Emitter {
    typealias EmitType = Void
    
    private let filePath: URL
    
    init(filePath: URL) {
        self.filePath = filePath
    }
    
    func emit(_ syntax: Syntax) throws -> Void {
        print(filePath.path(percentEncoded: false))
        guard let result = String(bytes: syntax.syntaxTextBytes, encoding: .utf8) else {
            return
        }
        print(result)
    }
}

struct OverwriteEmitter: Emitter {
    typealias EmitType = Void
    
    private let filePath: URL
    private let fileManager: FileManager = .default
    
    init(filePath: URL) {
        self.filePath = filePath
    }
    
    func emit(_ syntax: Syntax) throws -> Void {
        guard let result = String(bytes: syntax.syntaxTextBytes, encoding: .utf8) else {
            return
        }
        let destinationPath = filePath.path()
        try result.write(toFile: destinationPath, atomically: false, encoding: .utf8)
    }
}
