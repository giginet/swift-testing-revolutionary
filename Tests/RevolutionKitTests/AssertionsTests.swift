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

let fixturesWithSourceLocations: [ConversionTestFixture] = [
    .init(
        """
        XCTAssertTrue(isValid, "value should be true", line: 42)
        """,
        """
        #expect(isValid, "value should be true", sourceLocation: SourceLocation(line: 42))
        """
    ),
    .init(
        """
        XCTAssertTrue(
          isValid,
          line: 42
        )
        """,
        """
        #expect(
          isValid,sourceLocation: SourceLocation(
          line: 42)
        )
        """
    ),
    .init(
        """
        XCTAssertTrue(isValid, "value should be true", file: #file)
        """,
        """
        #expect(isValid, "value should be true", sourceLocation: SourceLocation(file: #file))
        """
    ),
    .init(
        """
        XCTAssertEqual(1 + 1, 2, "value should be 2", file: #file, line: 42)
        """,
        """
        #expect(1 + 1 == 2, "value should be 2", sourceLocation: SourceLocation(file: #file, line: 42))
        """
    ),
    .init(
        """
        XCTAssertNil(value, "value should be 2", file: #file, line: 42)
        """,
        """
        #expect(value == nil, "value should be 2", sourceLocation: SourceLocation(file: #file, line: 42))
        """
    ),
    .init(
        """
        XCTUnwrap(value, "value can be unwrapped", file: #file, line: 42)
        """,
        """
        #require(value, "value can be unwrapped", sourceLocation: SourceLocation(file: #file, line: 42))
        """
    ),
    .init(
        """
        XCTAssertThrowsError(try f(), "f() should raise error", file: #file, line: 42)
        """,
        """
        #expect(throws: (any Error).self, "f() should raise error", sourceLocation: SourceLocation(file: #file, line: 42)) { try f() }
        """
    ),
    .init(
        """
        XCTAssertThrowsError(try f(), "f() should raise error", file: #file, line: 42) { error in }
        """,
        """
        #expect("f() should raise error", sourceLocation: SourceLocation(file: #file, line: 42)) { try f() } throws: { error in }
        """
    ),
    .init(
        """
        XCTAssertNoThrow(try f(), "f() should raise error", file: #file, line: 42)
        """,
        """
        #expect(throws: Never.self, "f() should raise error", sourceLocation: SourceLocation(file: #file, line: 42)) { try f() }
        """
    ),
    .init(
        """
        XCTFail("error", file: #file, line: 42)
        """,
        """
        Issue.record("error", file: #file, line: 42)
        """
    ),
]

struct AssertionsTests {
    private let emitter = StringEmitter()
    
    @Test("AssertionRewriter can rewrite all assertions", arguments: fixtures)
    private func rewriteAssertions(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner()
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
    
    @Test("AssertionRewriter can rewrite all assertions with source locations", arguments: fixturesWithSourceLocations)
    private func rewriteAssertionsWithSourceLocations(_ fixture: ConversionTestFixture) async throws {
        let runner = Runner()
        
        let result = try runner.run(for: fixture.source, emitter: StringEmitter())
        #expect(result == fixture.expected)
    }
}
