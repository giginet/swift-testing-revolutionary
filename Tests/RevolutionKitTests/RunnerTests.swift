import Foundation
import Testing
@testable import RevolutionKit

private let fixtureLoader = FixtureLoader()

struct RunnerTests {
    private let runner = Runner()
    
    @Test("Runner can convert all fixtures", arguments: try! fixtureLoader.loadFixtures())
    func replaceAllFixtures(fixture: ConversionTestFixture) async throws {
        let source = fixture.source
        let converted = try runner.run(for: source, emitter: StringEmitter())
        #expect(converted == fixture.expected)
    }
}

private struct FixtureLoader {
    private let fileManager: FileManager = .default
    private let fixtureDir = URL(filePath: #filePath)
        .deletingLastPathComponent()
        .appending(component: "Fixtures")
    private var inputDir: URL { fixtureDir.appending(component: "Inputs") }
    private var expectsDir: URL { fixtureDir.appending(component: "Expects") }
    
    func loadFixtures() throws -> [ConversionTestFixture] {
        let inputFiles = try fileManager.contentsOfDirectory(atPath: inputDir.path())
        return inputFiles.map { fileName -> ConversionTestFixture? in
            let inputFilePath = inputDir.appending(component: fileName)
            let expectsFilePath = expectsDir.appending(component: fileName)
            
            guard let inputFileData = fileManager.contents(atPath: inputFilePath.path()),
                  let expectFileData = fileManager.contents(atPath: expectsFilePath.path()),
                  let inputFileString = String(data: inputFileData, encoding: .utf8),
                  let expectFileString = String(data: expectFileData, encoding: .utf8)
            else {
                return nil
            }
            
            return ConversionTestFixture(
                inputFileString,
                expectFileString
            )
        }
        .compactMap { $0 }
    }
}
