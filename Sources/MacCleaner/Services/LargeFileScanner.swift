import Foundation

@MainActor
class LargeFileScanner: ObservableObject {
    @Published var isScanning = false
    @Published var largeFiles: [LargeFile] = []
    @Published var scanProgress: Double = 0
    @Published var scanError: Error?
    
    private let minimumSize: Int64 = 100 * 1024 * 1024
    private var cancelled = false
    
    func scanDirectory(at path: String, minSize: Int64 = 100 * 1024 * 1024) {
        Task {
            isScanning = true
            largeFiles = []
            scanProgress = 0
            scanError = nil
            cancelled = false
            
            do {
                let files = try await scanFiles(at: path, minSize: minSize)
                largeFiles = files.sorted { $0.size > $1.size }
            } catch {
                self.scanError = error
            }
            
            isScanning = false
        }
    }
    
    func cancelScan() {
        cancelled = true
    }
    
    private func scanFiles(at path: String, minSize: Int64) async throws -> [LargeFile] {
        let fileManager = FileManager.default
        var files: [LargeFile] = []
        var processedCount = 0
        
        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return files
        }
        
        for case let url as URL in enumerator {
            if cancelled { break }
            
            let resourceValues = try url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey, URLResourceKey.fileSizeKey])
            
            if let isDirectory = resourceValues.isDirectory, !isDirectory {
                if let fileSize = resourceValues.fileSize, fileSize >= minSize {
                    let attributes = try fileManager.attributesOfItem(atPath: url.path)
                    let modDate = attributes[FileAttributeKey.modificationDate] as? Date ?? Date()
                    
                    let file = LargeFile(
                        path: url.path,
                        size: Int64(fileSize),
                        modificationDate: modDate,
                        fileType: url.pathExtension
                    )
                    files.append(file)
                }
            }
            
            processedCount += 1
            if processedCount % 100 == 0 {
                await MainActor.run {
                    scanProgress = Double(processedCount) / 1000
                }
            }
        }
        
        return files
    }
    
    func deleteFile(at path: String) async throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: path)
        
        await MainActor.run {
            largeFiles.removeAll { $0.path == path }
        }
    }
}