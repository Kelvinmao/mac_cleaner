import Foundation

struct StorageAnalysis: Identifiable, Codable {
    let id = UUID()
    let totalSpace: Int64
    let usedSpace: Int64
    let freeSpace: Int64
    let categories: [StorageCategory]
    
    var usedPercentage: Double {
        guard totalSpace > 0 else { return 0 }
        return Double(usedSpace) / Double(totalSpace) * 100
    }
    
    var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
    }
    
    var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
    }
    
    var formattedFreeSpace: String {
        ByteCountFormatter.string(fromByteCount: freeSpace, countStyle: .file)
    }
}

struct StorageCategory: Identifiable, Codable {
    let id = UUID()
    let name: String
    let size: Int64
    let color: String
    let fileCount: Int
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var percentageOfUsed: Double? {
        guard let parentSize = findParentUsedSpace() else { return nil }
        return Double(size) / Double(parentSize) * 100
    }
    
    private func findParentUsedSpace() -> Int64? {
        return nil
    }
}