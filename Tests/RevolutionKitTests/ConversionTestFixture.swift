import Foundation
import Testing

struct ConversionTestFixture: CustomTestStringConvertible {
    let fileName: String?
    let source: String
    let expected: String
    let sourceLocation: SourceLocation
    
    init(_ source: String, _ expected: String, _ sourceLocation: SourceLocation = #_sourceLocation, fileName: String? = nil) {
        self.source = source
        self.expected = expected
        self.sourceLocation = sourceLocation
        self.fileName = fileName
    }
    
    enum Expected {
        case identical
        case converted(String)
    }
    
    var testDescription: String {
        self.fileName ?? self.source
    }
}
