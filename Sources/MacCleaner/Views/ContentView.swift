import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .storage
    
    enum Tab: String, CaseIterable {
        case storage = "Storage"
        case largeFiles = "Large Files"
        case duplicates = "Duplicates"
        case cache = "Cache"
        
        var icon: String {
            switch self {
            case .storage: return "internaldrive"
            case .largeFiles: return "doc.on.doc.fill"
            case .duplicates: return "doc.on.doc"
            case .cache: return "trash.fill"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            Group {
                switch selectedTab {
                case .storage:
                    StorageView()
                case .largeFiles:
                    LargeFilesView()
                case .duplicates:
                    DuplicateFilesView()
                case .cache:
                    CacheView()
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}