import Foundation

struct TestFileFinder {
    private let fileManager: FileManager = .default
    
    func findTestFiles(in sources: [URL]) -> [URL] {
        sources.reduce([]) { (results, source) -> [URL] in
            results + walkFiles(in: source)
        }
        .filter { $0.pathExtension == "swift" }
    }
    
    private func walkFiles(in url: URL) -> [URL] {
        // if URL is not exist, return an empty array
        guard let isDirectory = isDirectory(url) else { return [] }
        
        // if URL is not a directory, return URL
        guard isDirectory else { return [url] }
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: url.path()) else {
            return []
        }
        
        let contentURLs = contents.compactMap(URL.init(string:))
        return contentURLs.flatMap { url in
            walkFiles(in: url)
        }
    }
    
    private func isDirectory(_ url: URL) -> Bool? {
        var isDir: ObjCBool = false
        let isExist = fileManager.fileExists(atPath: url.path(), isDirectory: &isDir)
        guard isExist else { return nil }
        return isDir.boolValue
    }
}
