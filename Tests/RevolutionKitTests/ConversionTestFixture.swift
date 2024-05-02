import Foundation

struct ConversionTestFixture {
    let source: String
    let expected: String
    
    init(_ source: String, _ expected: String) {
        self.source = source
        self.expected = expected
    }
    
    enum Expected {
        case identical
        case converted(String)
    }
}
