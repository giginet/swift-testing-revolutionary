import Testing
@testable import RevolutionKit

struct TestMethodNameConverterTests {
    private static let fixtures = [
        (true, "testDoSomething", "doSomething"),
        (false, "testDoSomething", "testDoSomething"),
        (true, "test_do_something", "do_something"),
        (false, "test_do_something", "test_do_something"),
        (true, "test", "test"),
        (false, "test", "test"),
    ]
    
    @Test("TestMethodNameConverter can convert method names", arguments: fixtures)
    func testConversion(enableStripping: Bool, input: String, expected: String) {
        let converter = TestMethodNameConverter(shouldStripPrefix: enableStripping)
        
        let actual = converter.convert(input)
        #expect(actual == expected)
    }
}
