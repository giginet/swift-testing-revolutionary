import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [ConversionTestFixture] = [
    .init(
        """
        XCTAssertEqual(
            1 + 1,
            2
        )
        """,
        """
        #expect(
            1 + 1 == 2
        )
        """
    ),
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
        XCTAssertFalse(isValid)
        """,
        """
        #expect(!isValid)
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
    .init(
        """
        try XCTUnwrap(value)
        """,
        """
        try #require(value)
        """
    ),
    .init(
        """
        XCTFail("error")
        """,
        """
        Issue.record("error")
        """
    ),
    .init(
        """
        XCTAssertThrowsError(try f())
        """,
        """
        #expect(throws: (any Error).self) { try f() }
        """
    ),
    .init(
        """
        XCTAssertNoThrow(try f())
        """,
        """
        #expect(throws: Never.self) { try f() }
        """
    ),
    .init(
        """
        XCTAssertThrowsError(try f()) { error in _ }
        """,
        """
        #expect { try f() } throws: { error in _ }
        """
    ),
    .init(
        """
        XCTAssert(isValid, "value should be true")
        """,
        """
        #expect(isValid, "value should be true")
        """
    ),
    .init(
        """
        XCTAssertTrue(isValid, "value should be true")
        """,
        """
        #expect(isValid, "value should be true")
        """
    ),
    .init(
        """
        XCTAssertFalse(isValid, "value should be false")
        """,
        """
        #expect(!isValid, "value should be false")
        """
    ),
    .init(
        """
        XCTAssertEqual(1 + 1, 2, "value should be 2")
        """,
        """
        #expect(1 + 1 == 2, "value should be 2")
        """
    ),    
]

struct AssertionsTests {
    private let emitter = StringEmitter()
    
    @Test("AssertionRewriter can rewrite all assertions", arguments: fixtures)
    private func rewriteAssertions(_ fixture: ConversionTestFixture) throws {
        let runner = Runner()
        
        let result = runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
