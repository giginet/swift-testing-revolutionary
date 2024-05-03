import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [ConversionTestFixture] = [
    .init(
        """
        XCTAssert(isValid)
        """,
        """
        #expect(isValid)
        """
    ),
    .init(
        """
        XCTAssertTrue(isValid)
        """,
        """
        #expect(isValid)
        """
    ),
    .init(
        """
        XCTAssertEqual(1 + 1, 2)
        """,
        """
        #expect(1 + 1 == 2)
        """
    ),
    .init(
        """
        XCTAssertNotEqual(1 + 1, 3)
        """,
        """
        #expect(1 + 1 != 3)
        """
    ),
    .init(
        """
        XCTAssertIdentical(value0, value1)
        """,
        """
        #expect(value0 === value1)
        """
    ),
    .init(
        """
        XCTAssertNotIdentical(value0, value1)
        """,
        """
        #expect(value0 !== value1)
        """
    ),
    .init(
        """
        XCTAssertGreaterThan(value0, value1)
        """,
        """
        #expect(value0 > value1)
        """
    ),
    .init(
        """
        XCTAssertGreaterThanOrEqual(value0, value1)
        """,
        """
        #expect(value0 >= value1)
        """
    ),
    .init(
        """
        XCTAssertLessThanOrEqual(value0, value1)
        """,
        """
        #expect(value0 <= value1)
        """
    ),
    .init(
        """
        XCTAssertLessThan(value0, value1)
        """,
        """
        #expect(value0 < value1)
        """
    ),
    .init(
        """
        XCTAssertNil(value)
        """,
        """
        #expect(value == nil)
        """
    ),
    .init(
        """
        XCTAssertNotNil(value)
        """,
        """
        #expect(value != nil)
        """
    ),
]

struct AssertionRewriterTests {
    private let emitter = StringEmitter()
    
    @Test("AssertionRewriter can rewrite all assertions", arguments: fixtures)
    private func rewriteAssertions(_ fixture: ConversionTestFixture) throws {
        let runner = Runner(rewriter: AssertionRewriter(globalOptions: .default))
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
