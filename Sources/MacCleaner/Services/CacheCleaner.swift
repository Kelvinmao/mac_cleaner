import Foundation

@MainActor
class CacheCleaner: ObservableObject {
    @Published var isScanning = false
    @Published var isCleaning = false
    @Published var cacheItems: [CacheItem] = []
    @Published var scanProgress: Double = 0
    @Published var cleanProgress: Double = 0
    @Published var scanError: Error?
    @Published var cleanError: Error?
    
    private var cancelled = false
    
    func scanCaches() {
        Task {
            isScanning = true
            cacheItems = []
            scanProgress = 0
            scanError = nil
            cancelled = false
            
            do {
                var items: [CacheItem] = []
                
                items.append(contentsOf: try await scanSystemCaches())
                items.append(contentsOf: try await scanUserCaches())
                items.append(contentsOf: try await scanApplicationCaches())
                items.append(contentsOf: try await scanBrowserCaches())
                items.append(contentsOf: try await scanLogFiles())
                
                cacheItems = items.sorted { $0.size > $1.size }
            } catch {
                self.scanError = error
            }
            
            isScanning = false
        }
    }
    
    func cancelScan() {
        cancelled = true
    }
    
    private func scanSystemCaches() async throws -> [CacheItem] {
        let paths = [
            "/Library/Caches",
            "/System/Library/Caches"
        ]
        
        var items: [CacheItem] = []
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                let size = try await calculateDirectorySize(at: path)
                if size > 0 {
                    items.append(CacheItem(
                        path: path,
                        size: size,
                        type: .system,
                        description: "System Cache"
                    ))
                }
            }
        }
        
        return items
    }
    
    private func scanUserCaches() async throws -> [CacheItem] {
        guard let homeDir = FileManager.default.homeDirectoryForCurrentUser.pathComponents.first else {
            return []
        }
        
        let paths = [
            "/\(homeDir)/Library/Caches",
            "/\(homeDir)/.cache"
        ]
        
        var items: [CacheItem] = []
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                let size = try await calculateDirectorySize(at: path)
                if size > 0 {
                    items.append(CacheItem(
                        path: path,
                        size: size,
                        type: .user,
                        description: "User Cache"
                    ))
                }
            }
        }
        
        return items
    }
    
    private func scanApplicationCaches() async throws -> [CacheItem] {
        let fileManager = FileManager.default
        var items: [CacheItem] = []
        
        guard let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return items
        }
        
        let appSupportPath = applicationSupport.path
        guard let enumerator = fileManager.enumerator(atPath: appSupportPath) else {
            return items
        }
        
        for case let component as String in enumerator {
            let fullPath = "\(appSupportPath)/\(component)"
            
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                let lowercased = component.lowercased()
                if lowercased.contains("cache") || lowercased.contains("temp") {
                    let size = try await calculateDirectorySize(at: fullPath)
                    if size > 0 {
                        items.append(CacheItem(
                            path: fullPath,
                            size: size,
                            type: .application,
                            description: "App Cache: \(component)"
                        ))
                    }
                }
            }
        }
        
        return items
    }
    
    private func scanBrowserCaches() async throws -> [CacheItem] {
        guard let homeDir = FileManager.default.homeDirectoryForCurrentUser.pathComponents.first else {
            return []
        }
        
        let browserPaths = [
            "/\(homeDir)/Library/Caches/Google/Chrome",
            "/\(homeDir)/Library/Caches/Microsoft/Edge",
            "/\(homeDir)/Library/Caches/Firefox",
            "/\(homeDir)/Library/Caches/Safari"
        ]
        
        var items: [CacheItem] = []
        
        for path in browserPaths {
            if FileManager.default.fileExists(atPath: path) {
                let size = try await calculateDirectorySize(at: path)
                if size > 0 {
                    let browserName = path.components(separatedBy: "/").last ?? "Browser"
                    items.append(CacheItem(
                        path: path,
                        size: size,
                        type: .browser,
                        description: "\(browserName) Cache"
                    ))
                }
            }
        }
        
        return items
    }
    
    private func scanLogFiles() async throws -> [CacheItem] {
        let paths = [
            "/var/log",
            "/Library/Logs"
        ]
        
        var items: [CacheItem] = []
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                let size = try await calculateDirectorySize(at: path)
                if size > 0 {
                    items.append(CacheItem(
                        path: path,
                        size: size,
                        type: .logs,
                        description: "System Logs"
                    ))
                }
            }
        }
        
        return items
    }
    
    private func calculateDirectorySize(at path: String) async throws -> Int64 {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey], options: [.skipsHiddenFiles]) {
            for case let url as URL in enumerator {
                if cancelled { break }
                
                let resourceValues = try url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey, URLResourceKey.fileSizeKey])
                
                if let isDirectory = resourceValues.isDirectory, !isDirectory {
                    if let fileSize = resourceValues.fileSize {
                        totalSize += Int64(fileSize)
                    }
                }
            }
        }
        
        return totalSize
    }
    
    func cleanSelected(items: [CacheItem]) async throws {
        isCleaning = true
        cleanProgress = 0
        cleanError = nil
        
        defer { isCleaning = false }
        
        let fileManager = FileManager.default
        
        for (index, item) in items.enumerated() {
            if fileManager.fileExists(atPath: item.path) {
                try fileManager.removeItem(atPath: item.path)
            }
            
            await MainActor.run {
                cleanProgress = Double(index + 1) / Double(items.count)
                cacheItems.removeAll { $0.id == item.id }
            }
        }
    }
    
    func cleanAll() async throws {
        try await cleanSelected(items: cacheItems)
    }
}