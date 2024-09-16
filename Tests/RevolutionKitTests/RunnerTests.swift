import Foundation
import Testing
@testable import RevolutionKit

struct RunnerTests {
    private let runner = Runner()
    
    @Test("Runner can convert all fixtures", arguments: try! FixtureLoader.loadFixtures())
    func replaceAllFixtures(fixture: ConversionTestFixture) async throws {
        let source = fixture.source
        let converted = try runner.run(for: source, emitter: StringEmitter())
        #expect(converted == fixture.expected)
    }
}

private enum FixtureLoader {
    private static let fixtureDir = URL(filePath: #filePath)
        .deletingLastPathComponent()
        .appending(component: "Fixtures")
    private static var inputDir: URL { fixtureDir.appending(component: "Inputs") }
    private static var expectsDir: URL { fixtureDir.appending(component: "Expects") }
    
    static func loadFixtures() throws -> [ConversionTestFixture] {
        let fileManager: FileManager = .default
        
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
                expectFileString,
                fileName: fileName
            )
        }
        .compactMap { $0 }
    }
}
