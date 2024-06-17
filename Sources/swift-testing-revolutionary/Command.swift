import Foundation
import ArgumentParser
import RevolutionKit

@main
struct SwiftTestingRevolutionaryCommand: AsyncParsableCommand {
    @Argument(help: "Test files to convert", completion: .file(extensions: ["swift"]))
    var files: [String]
    
    @Flag(help: "Whether overwrite converted files")
    var dryRun: Bool = false
    
    @Flag(inversion: .prefixedEnableDisable, help: "Whether converting testcase class to struct or not")
    var structConversion: Bool = true

    @Flag(inversion: .prefixedEnableDisable, help: "Whether stripping `test` prefix from each test method or not")
    var stripTestPrefix: Bool = true
    
    @Flag(inversion: .prefixedEnableDisable, help: "Whether adding `@Suite` to each test class")
    var addingSuite: Bool = true
    
    func run() async throws {
        let options = buildRunnerOptions()
        
        let runner = Runner(globalOptions: options)
        
        let fileURLs = files.compactMap(URL.init(string:))
        try await runner.run(for: fileURLs)
    }
    
    private func buildRunnerOptions() -> GlobalOptions {
        return .init(
            isDryRunMode: dryRun,
            enableStructConversion: structConversion,
            enableStrippingTestPrefix: stripTestPrefix,
            enableAddingSuite: addingSuite
        )
    }
}
