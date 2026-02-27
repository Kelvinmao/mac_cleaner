import Foundation
import CryptoKit

@MainActor
class DuplicateFileDetector: ObservableObject {
    @Published var isScanning = false
    @Published var duplicateGroups: [DuplicateFileGroup] = []
    @Published var scanProgress: Double = 0
    @Published var scanError: Error?
    
    private var cancelled = false
    private var fileHashes: [String: [DuplicateFile]] = [:]
    
    func scanDirectory(at path: String) {
        Task {
            isScanning = true
            duplicateGroups = []
            scanProgress = 0
            scanError = nil
            cancelled = false
            fileHashes = [:]
            
            do {
                try await scanFiles(at: path)
                await processDuplicates()
            } catch {
                self.scanError = error
            }
            
            isScanning = false
        }
    }
    
    func cancelScan() {
        cancelled = true
    }
    
    private func scanFiles(at path: String) async throws {
        let fileManager = FileManager.default
        var processedCount = 0
        
        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return
        }
        
        for case let url as URL in enumerator {
            if cancelled { break }
            
            do {
                let resourceValues = try url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey, URLResourceKey.fileSizeKey])
                
                if let isDirectory = resourceValues.isDirectory, !isDirectory {
                    if let fileSize = resourceValues.fileSize, fileSize > 0 {
                        let hash = try await calculateFileHash(at: url.path)
                        
                        let attributes = try fileManager.attributesOfItem(atPath: url.path)
                        let modDate = attributes[FileAttributeKey.modificationDate] as? Date ?? Date()
                        
                        let file = DuplicateFile(
                            path: url.path,
                            modificationDate: modDate
                        )
                        
                        if fileHashes[hash] == nil {
                            fileHashes[hash] = []
                        }
                        fileHashes[hash]?.append(file)
                    }
                }
            } catch {
                continue
            }
            
            processedCount += 1
            if processedCount % 100 == 0 {
                await MainActor.run {
                    scanProgress = Double(processedCount) / 1000
                }
            }
        }
    }
    
    private func processDuplicates() async {
        var groups: [DuplicateFileGroup] = []
        
        for (hash, files) in fileHashes {
            if files.count > 1 {
                if let firstFile = files.first {
                    let attributes = try? FileManager.default.attributesOfItem(atPath: firstFile.path)
                    let fileSize = attributes?[.size] as? Int ?? 0
                    
                    let group = DuplicateFileGroup(
                        hash: hash,
                        size: Int64(fileSize),
                        files: files
                    )
                    groups.append(group)
                }
            }
        }
        
        duplicateGroups = groups.sorted { $0.totalWastedSpace > $1.totalWastedSpace }
    }
    
    private func calculateFileHash(at path: String) async throws -> String {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        
        guard fileManager.fileExists(atPath: path, isDirectory: &isDir), !isDir.boolValue else {
            throw NSError(domain: "DuplicateFileDetector", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot calculate hash for directory"])
        }
        
        guard fileManager.isReadableFile(atPath: path) else {
            throw NSError(domain: "DuplicateFileDetector", code: 2, userInfo: [NSLocalizedDescriptionKey: "File is not readable"])
        }
        
        let url = URL(fileURLWithPath: path)
        
        let attributes = try fileManager.attributesOfItem(atPath: path)
        let fileSize = attributes[.size] as? Int ?? 0
        
        guard fileSize > 0 else {
            throw NSError(domain: "DuplicateFileDetector", code: 3, userInfo: [NSLocalizedDescriptionKey: "File is empty"])
        }
        
        let data = try Data(contentsOf: url)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func deleteFiles(at paths: [String]) async throws {
        let fileManager = FileManager.default
        
        for path in paths {
            try fileManager.removeItem(atPath: path)
        }
        
        await MainActor.run {
            duplicateGroups.removeAll { group in
                for path in paths {
                    if group.files.contains(where: { $0.path == path }) {
                        return true
                    }
                }
                return false
            }
        }
    }
    
    func deleteAllDuplicates(excluding keepPath: String) async throws {
        for group in duplicateGroups {
            let filesToDelete = group.files.filter { $0.path != keepPath }
            let pathsToDelete = filesToDelete.map { $0.path }
            try await deleteFiles(at: pathsToDelete)
        }
    }
}