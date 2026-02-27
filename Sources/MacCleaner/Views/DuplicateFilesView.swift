import SwiftUI

struct DuplicateFilesView: View {
    @StateObject private var detector = DuplicateFileDetector()
    @State private var selectedGroups: Set<UUID> = []
    @State private var showingDeleteAlert = false
    @State private var expandedGroups: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 0) {
            controlBar
                .padding()
            
            Divider()
            
            if detector.isScanning {
                VStack(spacing: 20) {
                    ProgressView(value: detector.scanProgress)
                        .scaleEffect(1.2)
                    Text("Scanning... \(Int(detector.scanProgress * 100))%")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = detector.scanError {
                VStack {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                    Button("Retry", action: startScan)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if detector.duplicateGroups.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No duplicates found")
                        .font(.headline)
                    Button("Start Scan", action: startScan)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                duplicateList
            }
        }
        .navigationTitle("Duplicate Files")
        .alert("Delete Duplicates", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelected()
            }
        } message: {
            Text("Are you sure you want to delete selected duplicates?")
        }
    }
    
    private var controlBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Found \(detector.duplicateGroups.count) duplicate groups")
                    .font(.subheadline)
                
                let totalWasted = detector.duplicateGroups.reduce(0) { $0 + $1.totalWastedSpace }
                Text("Total wasted space: \(ByteCountFormatter.string(fromByteCount: totalWasted, countStyle: .file))")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            if !detector.isScanning && !detector.duplicateGroups.isEmpty {
                Text("\(selectedGroups.count) groups selected")
                    .foregroundColor(.secondary)
                
                Button("Smart Select") {
                    selectedGroups = Set(detector.duplicateGroups.map { $0.id })
                }
                
                Button("Expand All") {
                    expandedGroups = Set(detector.duplicateGroups.map { $0.id })
                }
                
                Button("Collapse All") {
                    expandedGroups.removeAll()
                }
                
                Button("Cancel Selection") {
                    selectedGroups.removeAll()
                }
                .disabled(selectedGroups.isEmpty)
                
                Button("Delete Selected") {
                    showingDeleteAlert = true
                }
                .disabled(selectedGroups.isEmpty)
                .buttonStyle(.borderedProminent)
                
                Divider()
                    .frame(height: 20)
            }
            
            if detector.isScanning {
                Button("Cancel", action: detector.cancelScan)
                    .buttonStyle(.bordered)
            } else {
                Button("Scan", action: startScan)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var duplicateList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(detector.duplicateGroups) { group in
                    DisclosureGroup(isExpanded: Binding(
                        get: { expandedGroups.contains(group.id) },
                        set: { if $0 { expandedGroups.insert(group.id) } else { expandedGroups.remove(group.id) } }
                    )) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(group.files.enumerated()), id: \.element.id) { index, file in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            if index == 0 {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .help("This file will be kept")
                                            } else {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .help("This file will be deleted")
                                            }
                                            
                                            Text(URL(fileURLWithPath: file.path).lastPathComponent)
                                                .fontWeight(.medium)
                                        }
                                        
                                        Text(file.path)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        if index == 0 {
                                            Text("Keep")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.green)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.green.opacity(0.1))
                                                .cornerRadius(4)
                                        } else {
                                            Text("Delete")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.red)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.red.opacity(0.1))
                                                .cornerRadius(4)
                                        }
                                        
                                        Text(file.modificationDate, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(index == 0 ? Color.green.opacity(0.05) : Color.clear)
                                .cornerRadius(4)
                            }
                        }
                    } label: {
                        HStack {
                            CheckboxView(isSelected: selectedGroups.contains(group.id))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("\(group.files.count) copies")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text(group.formattedSize)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                HStack {
                                    Text("Hash: \(group.hash.prefix(16))...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Wasted: \(group.formattedWastedSpace)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding()
                        .background(selectedGroups.contains(group.id) ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                    }
                    
                    if group.id != detector.duplicateGroups.last?.id {
                        Divider()
                    }
                }
            }
            .padding()
        }
    }
    
    private func startScan() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        detector.scanDirectory(at: homeDir)
    }
    
    private func deleteSelected() {
        Task {
            for group in detector.duplicateGroups where selectedGroups.contains(group.id) {
                let pathsToDelete = group.files.dropFirst().map { $0.path }
                try? await detector.deleteFiles(at: pathsToDelete)
            }
            selectedGroups.removeAll()
        }
    }
}

struct CheckboxView: View {
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
            .foregroundColor(isSelected ? .blue : .secondary)
            .imageScale(.large)
    }
}