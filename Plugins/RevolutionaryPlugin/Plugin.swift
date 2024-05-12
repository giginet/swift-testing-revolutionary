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

struct SwiftTestingRevolutionaryXcodePlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let revolutionaryExecutable = try context.tool(named: "swift-testing-revolutionary")
        
        let allTestFiles = context.xcodeProject.filePaths
            .filter { $0.lastComponent.hasSuffix("Tests.swift") }
        
        let argumentsToExecute = arguments + allTestFiles.map { $0.string }
        try performTool(executablePath: revolutionaryExecutable.path.url, arguments: argumentsToExecute)
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
