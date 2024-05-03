import Foundation
import Testing

struct ConversionTestFixture {
    let source: String
    let expected: String
    let sourceLocation: SourceLocation
    
    init(_ source: String, _ expected: String, _ line: UInt = #line) {
        self.source = source
        self.expected = expected
        self.sourceLocation = SourceLocation(line: Int(line))
    }
    
    enum Expected {
        case identical
        case converted(String)
    }
}
