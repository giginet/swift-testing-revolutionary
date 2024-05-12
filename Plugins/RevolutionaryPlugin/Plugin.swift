import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

@main
struct SwiftTestingRevolutionaryPlugin: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let revolutionaryExecutable = try context.tool(named: "swift-testing-revolutionary")
        
        let allTestTargets = context.package.targets(ofType: SwiftSourceModuleTarget.self)
            .filter { $0.kind == .test }
        
        let argumentsToExecute = arguments + allTestTargets.map { $0.directory.string }
        try performTool(executablePath: revolutionaryExecutable.path.url, arguments: argumentsToExecute)
    }
}

#if canImport(XcodeProjectPlugin)

extension SwiftTestingRevolutionaryPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        let revolutionaryExecutable = try context.tool(named: "swift-testing-revolutionary")
        
        var extractor = ArgumentExtractor(arguments)
        let targetNames = extractor.extractOption(named: "target")
        
        let allTestFiles = targetNames.reduce([]) { files, targetName -> [File] in
            guard let target = context.xcodeProject.target(named: targetName) else {
                return files
            }
            
            let allTestFiles = target.inputFiles
                .filter { $0.path.lastComponent.hasSuffix("Tests.swift") }
            return files + allTestFiles
        }
        
        let argumentsToExecute = extractor.remainingArguments + allTestFiles.map { $0.path.string }
        try performTool(executablePath: revolutionaryExecutable.path.url, arguments: argumentsToExecute)
    }
}

extension XcodeProject {
    fileprivate func target(named targetName: String) -> XcodeTarget? {
        targets.first { $0.displayName == targetName }
    }
}

#endif

private func performTool(executablePath: URL, arguments: [String]) throws {
    let process = try Process.run(executablePath, arguments: arguments)
    process.waitUntilExit()
                
    if process.terminationReason == .exit && process.terminationStatus == 0 {
        print("Converting all test files is succeeded")
    }
}

extension Path {
    fileprivate var url: URL {
        URL(filePath: string)
    }
}
