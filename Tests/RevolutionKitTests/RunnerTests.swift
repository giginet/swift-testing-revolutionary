import Foundation
import Testing
@testable import RevolutionKit

struct RunnerTests {
    private let runner = Runner()

    @Test
    func replaceImportStatement() {
        let source = """
import Foundation
@testable import MyApp
import XCTest

final class APIClientTests: XCTestCase {
    func testFetchProducts() async throws {
        let client = APIClient(baseURL: stagingBaseURL)
        let product = try await client.fetch(id: 100)
        XCTAssertEqual(
            product.name,
            "Nice Cream"
        )
        XCTAssertTrue(product.isAvailable)
        XCTAssertGreaterThan(product.price, 100)
        XCTAssertNotNil(product.flavor)
    }
}
"""
        let converted = runner.run(for: source, emitter: StringEmitter())
        let expected = """
import Foundation
@testable import MyApp
import Testing

struct APIClientTests {
    @Test func fetchProducts() async throws {
        let client = APIClient(baseURL: stagingBaseURL)
        let product = try await client.fetch(id: 100)
        #expect(
            product.name == "Nice Cream"
        )
        #expect(product.isAvailable)
        #expect(product.price > 100)
        #expect(product.flavor != nil)
    }
}
"""
        #expect(converted == expected)
    }
}
