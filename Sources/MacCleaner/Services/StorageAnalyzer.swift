import Foundation

@MainActor
class StorageAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysis: StorageAnalysis?
    @Published var analyzeError: Error?
    
    func analyze() {
        Task {
            isAnalyzing = true
            analyzeError = nil
            
            do {
                let analysis = try await performAnalysis()
                self.analysis = analysis
            } catch {
                self.analyzeError = error
            }
            
            isAnalyzing = false
        }
    }
    
    private func performAnalysis() async throws -> StorageAnalysis {
        let fileManager = FileManager.default
        
        guard let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: "/") else {
            throw NSError(domain: "StorageAnalyzer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access file system"])
        }
        
        let totalSpace = systemAttributes[.systemSize] as? Int64 ?? 0
        let freeSpace = systemAttributes[.systemFreeSize] as? Int64 ?? 0
        let usedSpace = totalSpace - freeSpace
        
        let categories = try await analyzeCategories()
        
        return StorageAnalysis(
            totalSpace: totalSpace,
            usedSpace: usedSpace,
            freeSpace: freeSpace,
            categories: categories
        )
    }
    
    private func analyzeCategories() async throws -> [StorageCategory] {
        let fileManager = FileManager.default
        var categories: [StorageCategory] = []
        
        guard let homeDir = fileManager.homeDirectoryForCurrentUser.pathComponents.first else {
            return []
        }
        
        let homePath = "/\(homeDir)"
        
        let homeSize = try await calculateDirectorySize(at: homePath)
        if homeSize > 0 {
            categories.append(StorageCategory(
                name: "Home",
                size: homeSize,
                color: "#FF6B6B",
                fileCount: 0
            ))
        }
        
        let applicationsPath = "/Applications"
        if fileManager.fileExists(atPath: applicationsPath) {
            let appSize = try await calculateDirectorySize(at: applicationsPath)
            if appSize > 0 {
                categories.append(StorageCategory(
                    name: "Applications",
                    size: appSize,
                    color: "#4ECDC4",
                    fileCount: 0
                ))
            }
        }
        
        let systemPath = "/System"
        if fileManager.fileExists(atPath: systemPath) {
            let systemSize = try await calculateDirectorySize(at: systemPath)
            if systemSize > 0 {
                categories.append(StorageCategory(
                    name: "System",
                    size: systemSize,
                    color: "#95E1D3",
                    fileCount: 0
                ))
            }
        }
        
        let libraryPath = "/Library"
        if fileManager.fileExists(atPath: libraryPath) {
            let librarySize = try await calculateDirectorySize(at: libraryPath)
            if librarySize > 0 {
                categories.append(StorageCategory(
                    name: "Library",
                    size: librarySize,
                    color: "#F38181",
                    fileCount: 0
                ))
            }
        }
        
        let userLibraryPath = "\(homePath)/Library"
        if fileManager.fileExists(atPath: userLibraryPath) {
            let userLibSize = try await calculateDirectorySize(at: userLibraryPath)
            if userLibSize > 0 {
                categories.append(StorageCategory(
                    name: "User Library",
                    size: userLibSize,
                    color: "#AA96DA",
                    fileCount: 0
                ))
            }
        }
        
        let downloadsPath = "\(homePath)/Downloads"
        if fileManager.fileExists(atPath: downloadsPath) {
            let downloadsSize = try await calculateDirectorySize(at: downloadsPath)
            if downloadsSize > 0 {
                categories.append(StorageCategory(
                    name: "Downloads",
                    size: downloadsSize,
                    color: "#FCBAD3",
                    fileCount: 0
                ))
            }
        }
        
        let documentsPath = "\(homePath)/Documents"
        if fileManager.fileExists(atPath: documentsPath) {
            let documentsSize = try await calculateDirectorySize(at: documentsPath)
            if documentsSize > 0 {
                categories.append(StorageCategory(
                    name: "Documents",
                    size: documentsSize,
                    color: "#A8D8EA",
                    fileCount: 0
                ))
            }
        }
        
        return categories.sorted { $0.size > $1.size }
    }
    
    private func calculateDirectorySize(at path: String) async throws -> Int64 {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey], options: [.skipsHiddenFiles]) {
            for case let url as URL in enumerator {
                let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey])
                
                if let isDirectory = resourceValues.isDirectory, !isDirectory {
                    if let fileSize = resourceValues.fileSize {
                        totalSize += Int64(fileSize)
                    }
                }
            }
        }
        
        return totalSize
    }
}