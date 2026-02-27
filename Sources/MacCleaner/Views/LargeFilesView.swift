import SwiftUI

struct LargeFilesView: View {
    @StateObject private var scanner = LargeFileScanner()
    @State private var selectedFiles: Set<UUID> = []
    @State private var showingDeleteAlert = false
    @State private var minSize: Double = 100
    
    var body: some View {
        VStack(spacing: 0) {
            controlBar
                .padding()
            
            Divider()
            
            if scanner.isScanning {
                VStack(spacing: 20) {
                    ProgressView(value: scanner.scanProgress)
                        .scaleEffect(1.2)
                    Text("Scanning... \(Int(scanner.scanProgress * 100))%")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = scanner.scanError {
                VStack {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                    Button("Retry", action: startScan)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if scanner.largeFiles.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No large files found")
                        .font(.headline)
                    Button("Start Scan", action: startScan)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                fileList
            }
        }
        .navigationTitle("Large Files")
        .alert("Delete Files", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelected()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedFiles.count) file(s)?")
        }
    }
    
    private var controlBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Minimum Size: \(Int(minSize)) MB")
                    .font(.subheadline)
                Slider(value: $minSize, in: 10...1000, step: 10)
                    .frame(width: 200)
            }
            
            Spacer()
            
            if !scanner.isScanning && !scanner.largeFiles.isEmpty {
                Text("\(selectedFiles.count) selected")
                    .foregroundColor(.secondary)
                
                Button("Cancel Selection") {
                    selectedFiles.removeAll()
                }
                .disabled(selectedFiles.isEmpty)
                
                Button("Delete Selected") {
                    showingDeleteAlert = true
                }
                .disabled(selectedFiles.isEmpty)
                .buttonStyle(.borderedProminent)
                
                Divider()
                    .frame(height: 20)
            }
            
            if scanner.isScanning {
                Button("Cancel", action: scanner.cancelScan)
                    .buttonStyle(.bordered)
            } else {
                Button("Scan", action: startScan)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var fileList: some View {
        Table(scanner.largeFiles, selection: $selectedFiles) {
            TableColumn("Name") { file in
                Text(URL(fileURLWithPath: file.path).lastPathComponent)
                    .fontWeight(.medium)
            }
            
            TableColumn("Path") { file in
                Text(file.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            TableColumn("Size") { file in
                Text(file.formattedSize)
                    .frame(maxWidth: 100, alignment: .trailing)
            }
            
            TableColumn("Type") { file in
                Text(file.fileType.isEmpty ? "File" : file.fileType.uppercased())
                    .font(.caption)
                    .frame(maxWidth: 80, alignment: .leading)
            }
            
            TableColumn("Modified") { file in
                Text(file.modificationDate, style: .date)
                    .font(.caption)
            }
        }
        .tableStyle(.inset(alternatesRowBackgrounds: true))
    }
    
    private func startScan() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        scanner.scanDirectory(at: homeDir, minSize: Int64(minSize * 1024 * 1024))
    }
    
    private func deleteSelected() {
        Task {
            for file in scanner.largeFiles where selectedFiles.contains(file.id) {
                try? await scanner.deleteFile(at: file.path)
            }
            selectedFiles.removeAll()
        }
    }
}