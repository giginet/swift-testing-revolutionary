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

@resultBuilder
struct FixtureBuilder {
    public static func buildBlock(sourceLocation: SourceLocation = #_sourceLocation, _ source: String, _ expected: String) -> (String, String, SourceLocation) {
        (source, expected, sourceLocation)
    }
}

typealias Fixture = ConversionTestFixture

extension Fixture {
    init(@FixtureBuilder fixture: () -> (String, String, SourceLocation)) {
        let parameters = fixture()
        self.source = parameters.0
        self.expected = parameters.1
        self.sourceLocation = parameters.2
        self.fileName = nil
    }
}
