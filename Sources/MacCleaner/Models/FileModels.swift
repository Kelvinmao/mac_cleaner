import Foundation

struct LargeFile: Identifiable, Codable {
    let id = UUID()
    let path: String
    let size: Int64
    let modificationDate: Date
    let fileType: String
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct DuplicateFileGroup: Identifiable, Codable {
    let id = UUID()
    let hash: String
    let size: Int64
    let files: [DuplicateFile]
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var totalWastedSpace: Int64 {
        size * Int64(files.count - 1)
    }
    
    var formattedWastedSpace: String {
        ByteCountFormatter.string(fromByteCount: totalWastedSpace, countStyle: .file)
    }
}

struct DuplicateFile: Identifiable, Codable {
    let id = UUID()
    let path: String
    let modificationDate: Date
}

struct CacheItem: Identifiable, Codable {
    let id = UUID()
    let path: String
    let size: Int64
    let type: CacheType
    let description: String
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

enum CacheType: String, Codable, CaseIterable {
    case system = "System"
    case user = "User"
    case application = "Application"
    case browser = "Browser"
    case logs = "Logs"
}