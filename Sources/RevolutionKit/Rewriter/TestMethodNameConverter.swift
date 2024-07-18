import Foundation

struct TestMethodNameConverter {
    let shouldStripPrefix: Bool
    private let testPrefix = "test"
    private let snakeCasePrefix = "test_"
    
    /// Strip first `test` prefix from test case names.
    /// `testCamelCase` -> `camelCase`
    /// `test_snake_case` -> `snake_case`
    /// `test` -> `test`
    func convert(_ testMethodName: String) -> String {
        guard shouldStripPrefix else { return testMethodName }
        
        if testMethodName.hasPrefix(snakeCasePrefix) {
            return testMethodName.strippedFirst(snakeCasePrefix.count)
        } else if testMethodName == testPrefix {
            return testMethodName
        } else if testMethodName.hasPrefix(testPrefix) {
            return testMethodName
                .strippedFirst(testPrefix.count)
                .lowercasedFirstLetter()
        }
        assertionFailure("Unexpected call")
        return testMethodName
    }
}

extension String {
    fileprivate func strippedFirst(_ k: Int) -> String {
        var mutating = self
        mutating.removeFirst(k)
        return mutating
    }
    
    fileprivate func lowercasedFirstLetter() -> String {
        guard let firstLetter = first else { return self }
        return firstLetter.lowercased() + self[index(after: startIndex)..<endIndex]
    }
}
