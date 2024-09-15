import Foundation
import Testing

struct ConversionTestFixture: CustomTestStringConvertible {
    let source: String
    let expected: String
    let sourceLocation: SourceLocation
    
    init(_ source: String, _ expected: String, _ sourceLocation: SourceLocation = #_sourceLocation) {
        self.source = source
        self.expected = expected
        self.sourceLocation = sourceLocation
    }
    
    enum Expected {
        case identical
        case converted(String)
    }
    
    var testDescription: String {
        self.source
    }
}
