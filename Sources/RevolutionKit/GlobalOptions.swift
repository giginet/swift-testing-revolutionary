import Foundation

/// Struct to contains the global options
package struct GlobalOptions {
    /// Whether to run in dry-run mode
    var isDryRunMode: Bool
    
    /// Disable backup mode or enable backup mode with the backup directory
    var backupMode: BackUpMode
    
    /// Whether to skip convertion if the files contain the not supported API
    var shouldSkipIfUnsupportedAPI: Bool
    
    /// Whether to enable conversion of test classes to structs
    var enableStructConversion: Bool
    
    /// Whether to enable to strip `test` prefixes of each test case
    var enableStrippingTestPrefix: Bool
    
    package enum BackUpMode {
        case disabled
        case enabled(URL)
    }
    
    package init(
        isDryRunMode: Bool = false,
        backupMode: BackUpMode = .disabled,
        shouldSkipIfUnsupportedAPI: Bool = true,
        enableStructConversion: Bool = true,
        enableStrippingTestPrefix: Bool = true
    ) {
        self.isDryRunMode = isDryRunMode
        self.backupMode = backupMode
        self.shouldSkipIfUnsupportedAPI = shouldSkipIfUnsupportedAPI
        self.enableStructConversion = enableStructConversion
        self.enableStrippingTestPrefix = enableStrippingTestPrefix
    }
}

extension GlobalOptions {
    package static let `default`: Self = .init()
}
