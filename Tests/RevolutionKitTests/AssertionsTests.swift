import Foundation
import Testing
@testable import RevolutionKit

private let fixtures: [ConversionTestFixture] = [
    Fixture {
        """
        XCTAssertEqual(
            1 + 1,
            2
        )
        """
        """
        #expect(
            1 + 1 == 2
        )
        """
    },
    Fixture {
        """
        XCTAssert(isValid)
        """
        """
        #expect(isValid)
        """
    },
    Fixture {
        """
        XCTAssertTrue(isValid)
        """
        """
        #expect(isValid)
        """
    },
    Fixture {
        """
        XCTAssertFalse(isValid)
        """
        """
        #expect(!isValid)
        """
    },
    Fixture {
        """
        XCTAssertEqual(1 + 1, 2)
        """
        """
        #expect(1 + 1 == 2)
        """
    },
    Fixture {
        """
        XCTAssertNotEqual(1 + 1, 3)
        """
        """
        #expect(1 + 1 != 3)
        """
    },
    Fixture {
        """
        XCTAssertIdentical(value0, value1)
        """
        """
        #expect(value0 === value1)
        """
    },
    Fixture {
        """
        XCTAssertNotIdentical(value0, value1)
        """
        """
        #expect(value0 !== value1)
        """
    },
    Fixture {
        """
        XCTAssertGreaterThan(value0, value1)
        """
        """
        #expect(value0 > value1)
        """
    },
    Fixture {
        """
        XCTAssertGreaterThanOrEqual(value0, value1)
        """
        """
        #expect(value0 >= value1)
        """
    },
    Fixture {
        """
        XCTAssertLessThanOrEqual(value0, value1)
        """
        """
        #expect(value0 <= value1)
        """
    },
    Fixture {
        """
        XCTAssertLessThan(value0, value1)
        """
        """
        #expect(value0 < value1)
        """
    },
    Fixture {
        """
        XCTAssertNil(value)
        """
        """
        #expect(value == nil)
        """
    },
    Fixture {
        """
        XCTAssertNotNil(value)
        """
        """
        #expect(value != nil)
        """
    },
    Fixture {
        """
        try XCTUnwrap(value)
        """
        """
        try #require(value)
        """
    },
    Fixture {
        """
        XCTFail("error")
        """
        """
        Issue.record("error")
        """
    },
    Fixture {
        """
        XCTAssertThrowsError(try f())
        """
        """
        #expect(throws: (any Error).self) { try f() }
        """
    },
    Fixture {
        """
        XCTAssertNoThrow(try f())
        """
        """
        #expect(throws: Never.self) { try f() }
        """
    },
    Fixture {
        """
        XCTAssertThrowsError(try f()) { error in _ }
        """
        """
        #expect { try f() } throws: { error in _ }
        """
    },
    Fixture {
        """
        XCTAssert(isValid, "value should be true")
        """
        """
        #expect(isValid, "value should be true")
        """
    },
    Fixture {
        """
        XCTAssertTrue(isValid, "value should be true")
        """
        """
        #expect(isValid, "value should be true")
        """
    },
    Fixture {
        """
        XCTAssertFalse(isValid, "value should be false")
        """
        """
        #expect(!isValid, "value should be false")
        """
    },
    Fixture {
        """
        XCTAssertEqual(1 + 1, 2, "value should be 2")
        """
        """
        #expect(1 + 1 == 2, "value should be 2")
        """
    },
]

let fixturesWithSourceLocations: [ConversionTestFixture] = [
    Fixture {
        """
        XCTAssertTrue(isValid, "value should be true", line: 42)
        """
        """
        #expect(isValid, "value should be true", sourceLocation: SourceLocation(line: 42))
        """
    },
    Fixture {
        """
        XCTAssertTrue(
          isValid,
          line: 42
        )
        """
        """
        #expect(
          isValid,sourceLocation: SourceLocation(
          line: 42)
        )
        """
    },
    Fixture {
        """
        XCTAssertTrue(isValid, "value should be true", file: #file)
        """
        """
        #expect(isValid, "value should be true", sourceLocation: SourceLocation(file: #file))
        """
    },
    Fixture {
        """
        XCTAssertEqual(1 + 1, 2, "value should be 2", file: #file, line: 42)
        """
        """
        #expect(1 + 1 == 2, "value should be 2", sourceLocation: SourceLocation(file: #file, line: 42))
        """
    },
    Fixture {
        """
        XCTAssertNil(value, "value should be 2", file: #file, line: 42)
        """
        """
        #expect(value == nil, "value should be 2", sourceLocation: SourceLocation(file: #file, line: 42))
        """
    },
    Fixture {
        """
        XCTUnwrap(value, "value can be unwrapped", file: #file, line: 42)
        """
        """
        #require(value, "value can be unwrapped", sourceLocation: SourceLocation(file: #file, line: 42))
        """
    },
    Fixture {
        """
        XCTAssertThrowsError(try f(), "f() should raise error", file: #file, line: 42)
        """
        """
        #expect(throws: (any Error).self, "f() should raise error", sourceLocation: SourceLocation(file: #file, line: 42)) { try f() }
        """
    },
    Fixture {
        """
        XCTAssertThrowsError(try f(), "f() should raise error", file: #file, line: 42) { error in }
        """
        """
        #expect("f() should raise error", sourceLocation: SourceLocation(file: #file, line: 42)) { try f() } throws: { error in }
        """
    },
    Fixture {
        """
        XCTAssertNoThrow(try f(), "f() should raise error", file: #file, line: 42)
        """
        """
        #expect(throws: Never.self, "f() should raise error", sourceLocation: SourceLocation(file: #file, line: 42)) { try f() }
        """
    },
    Fixture {
        """
        XCTFail("error", file: #file, line: 42)
        """
        """
        Issue.record("error", file: #file, line: 42)
        """
    },
]

@Suite("Tests rewrite all assertions")
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
