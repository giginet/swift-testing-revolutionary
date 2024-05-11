import Foundation
import SwiftSyntax

protocol RequireConverter: MacroAssertionConverter { }

extension RequireConverter {
    var macroName: String { "require" }
}

struct XCTUnwrapConverter: SingleArgumentConverter, RequireConverter {
    let xcTestAssertionName = "XCTUnwrap"
}

