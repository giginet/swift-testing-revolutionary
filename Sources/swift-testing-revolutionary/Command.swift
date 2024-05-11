import ArgumentParser
import RevolutionKit

@main
struct SwiftTestingRevolutionaryCommand: AsyncParsableCommand {
    @Flag(help: "Whether overwrite converted files")
    var dryRun: Bool = false
    
    @Flag(help: "Whether skipping unsupported APIs")
    var skipUnsupportedAPI: Bool = false
    
    @Flag(inversion: .prefixedEnableDisable, help: "Whether converting testcase class to struct or not")
    var structConversion: Bool = true

    @Flag(inversion: .prefixedEnableDisable, help: "Whether stripping `test` prefix from each test method or not")
    var stripTestPrefix: Bool = true
    
    func run() async throws {
        let runner = Runner()
        
        try await runner.run(for: [])
    }
}
