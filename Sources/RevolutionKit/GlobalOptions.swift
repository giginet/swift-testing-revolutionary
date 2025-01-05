import Foundation

/// Struct to contains the global options
package struct GlobalOptions: Sendable {
    /// Whether to run in dry-run mode
    var isDryRunMode: Bool
    
    /// Whether to enable conversion of test classes to structs
    var enableStructConversion: Bool
    
    /// Whether to enable to strip `test` prefixes of each test case
    var enableStrippingTestPrefix: Bool
    
    /// Whether to add `@Suite` to each test class
    var enableAddingSuite: Bool
    
    /// Whether to put attributes on the same line as the declaration or on top of it
    var attributesOnSameLine: Bool
    
    package enum BackUpMode {
        case disabled
        case enabled(URL)
    }
    
    package init(
        isDryRunMode: Bool = false,
        enableStructConversion: Bool = true,
        enableStrippingTestPrefix: Bool = true,
        enableAddingSuite: Bool = true,
        attributesOnSameLine: Bool = true
    ) {
        self.isDryRunMode = isDryRunMode
        self.enableStructConversion = enableStructConversion
        self.enableStrippingTestPrefix = enableStrippingTestPrefix
        self.enableAddingSuite = enableAddingSuite
        self.attributesOnSameLine = attributesOnSameLine
    }
}

extension GlobalOptions {
    package static let `default`: Self = .init()
}
