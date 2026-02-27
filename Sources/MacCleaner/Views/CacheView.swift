import SwiftUI

struct CacheView: View {
    @StateObject private var cleaner = CacheCleaner()
    @State private var selectedItems: Set<UUID> = []
    @State private var showingDeleteAlert = false
    @State private var filterType: CacheType?
    
    var body: some View {
        VStack(spacing: 0) {
            controlBar
                .padding()
            
            Divider()
            
            if cleaner.isScanning {
                VStack(spacing: 20) {
                    ProgressView(value: cleaner.scanProgress)
                        .scaleEffect(1.2)
                    Text("Scanning... \(Int(cleaner.scanProgress * 100))%")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if cleaner.isCleaning {
                VStack(spacing: 20) {
                    ProgressView(value: cleaner.cleanProgress)
                        .scaleEffect(1.2)
                    Text("Cleaning... \(Int(cleaner.cleanProgress * 100))%")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = cleaner.scanError {
                VStack {
                    Text("Scan Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                    Button("Retry", action: startScan)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = cleaner.cleanError {
                VStack {
                    Text("Clean Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                    Button("Retry", action: cleanSelected)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if cleaner.cacheItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No cache found")
                        .font(.headline)
                    Button("Start Scan", action: startScan)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                filteredCacheList
            }
        }
        .navigationTitle("Cache Cleaner")
        .alert("Clean Cache", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clean", role: .destructive) {
                cleanSelected()
            }
        } message: {
            let totalSize = itemsToClean.reduce(0) { $0 + $1.size }
            Text("Are you sure you want to clean \(selectedItems.count) item(s)?\nTotal: \(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))")
        }
    }
    
    private var itemsToClean: [CacheItem] {
        cleaner.cacheItems.filter { selectedItems.contains($0.id) }
    }
    
    private var controlBar: some View {
        HStack {
            Picker("Filter", selection: $filterType) {
                Text("All").tag(CacheType?.none)
                ForEach(CacheType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(CacheType?.some(type))
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            Spacer()
            
            if !cleaner.isScanning && !cleaner.isCleaning && !cleaner.cacheItems.isEmpty {
                let totalSize = itemsToClean.reduce(0) { $0 + $1.size }
                Text("\(selectedItems.count) selected (\(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)))")
                    .foregroundColor(.secondary)
                
                Button("Select All") {
                    selectedItems = Set(filteredItems.map { $0.id })
                }
                
                Button("Cancel Selection") {
                    selectedItems.removeAll()
                }
                .disabled(selectedItems.isEmpty)
                
                Button("Clean Selected") {
                    showingDeleteAlert = true
                }
                .disabled(selectedItems.isEmpty)
                .buttonStyle(.borderedProminent)
                
                Divider()
                    .frame(height: 20)
            }
            
            if cleaner.isScanning || cleaner.isCleaning {
                Button("Cancel", action: cleaner.cancelScan)
                    .buttonStyle(.bordered)
            } else {
                Button("Scan", action: startScan)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var filteredItems: [CacheItem] {
        if let filterType = filterType {
            return cleaner.cacheItems.filter { $0.type == filterType }
        }
        return cleaner.cacheItems
    }
    
    private var filteredCacheList: some View {
        Table(filteredItems, selection: $selectedItems) {
            TableColumn("Type") { item in
                HStack {
                    Circle()
                        .fill(colorForType(item.type))
                        .frame(width: 8, height: 8)
                    Text(item.type.rawValue)
                        .fontWeight(.medium)
                }
            }
            
            TableColumn("Description") { item in
                Text(item.description)
                    .fontWeight(.medium)
            }
            
            TableColumn("Path") { item in
                Text(item.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            TableColumn("Size") { item in
                Text(item.formattedSize)
                    .frame(maxWidth: 100, alignment: .trailing)
                    .fontWeight(.semibold)
                    .foregroundColor(item.size > 100_000_000 ? .orange : .primary)
            }
        }
        .tableStyle(.inset(alternatesRowBackgrounds: true))
    }
    
    private func colorForType(_ type: CacheType) -> Color {
        switch type {
        case .system: return .red
        case .user: return .blue
        case .application: return .green
        case .browser: return .orange
        case .logs: return .purple
        }
    }
    
    private func startScan() {
        cleaner.scanCaches()
    }
    
    private func cleanSelected() {
        Task {
            let itemsToClean = cleaner.cacheItems.filter { selectedItems.contains($0.id) }
            try? await cleaner.cleanSelected(items: itemsToClean)
            selectedItems.removeAll()
        }
    }
}