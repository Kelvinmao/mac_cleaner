import SwiftUI

struct StorageView: View {
    @StateObject private var analyzer = StorageAnalyzer()
    
    var body: some View {
        VStack(spacing: 20) {
            if let analysis = analyzer.analysis {
                StorageOverviewView(analysis: analysis)
                Divider()
                StorageCategoriesView(categories: analysis.categories, usedSpace: analysis.usedSpace)
            } else if analyzer.isAnalyzing {
                ProgressView("Analyzing storage...")
                    .scaleEffect(1.5)
            } else if let error = analyzer.analyzeError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Storage Analysis")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    analyzer.analyze()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            analyzer.analyze()
        }
    }
}

struct StorageOverviewView: View {
    let analysis: StorageAnalysis
    
    var body: some View {
        HStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Space")
                    .font(.headline)
                Text(analysis.formattedTotalSpace)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Used Space")
                    .font(.headline)
                Text(analysis.formattedUsedSpace)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Free Space")
                    .font(.headline)
                Text(analysis.formattedFreeSpace)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("Usage")
                    .font(.headline)
                Text(String(format: "%.1f%%", analysis.usedPercentage))
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
        .overlay(
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
        )
    }
}

struct StorageCategoriesView: View {
    let categories: [StorageCategory]
    let usedSpace: Int64
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Storage Categories")
                .font(.headline)
            
            HStack(alignment: .top, spacing: 20) {
                PieChartView(categories: categories, usedSpace: usedSpace)
                    .frame(width: 300, height: 300)
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(categories) { category in
                        HStack {
                            Circle()
                                .fill(Color(hex: category.color))
                                .frame(width: 12, height: 12)
                            
                            Text(category.name)
                                .frame(width: 100, alignment: .leading)
                            
                            Spacer()
                            
                            Text(category.formattedSize)
                                .frame(width: 100, alignment: .trailing)
                            
                            if let percentage = category.percentageOfUsed {
                                Text(String(format: "%.1f%%", percentage))
                                    .frame(width: 60, alignment: .trailing)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct PieChartView: View {
    let categories: [StorageCategory]
    let usedSpace: Int64
    
    var body: some View {
        ZStack {
            ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                if usedSpace > 0 {
                    let startAngle = startAngle(for: index)
                    let endAngle = endAngle(for: index, startAngle: startAngle)
                    
                    if startAngle != endAngle {
                        Path { path in
                            path.move(to: CGPoint(x: 150, y: 150))
                            path.addArc(center: CGPoint(x: 150, y: 150),
                                     radius: 130,
                                     startAngle: startAngle,
                                     endAngle: endAngle,
                                     clockwise: false)
                            path.closeSubpath()
                        }
                        .fill(Color(hex: category.color))
                        .overlay(
                            Text(category.formattedSize)
                                .font(.caption)
                                .foregroundColor(.white)
                                .position(textPosition(for: index, startAngle: startAngle, endAngle: endAngle))
                        )
                    }
                }
            }
        }
        .frame(width: 300, height: 300)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let accumulatedSize = categories[0..<index].reduce(0) { $0 + $1.size }
        return Angle(degrees: Double(accumulatedSize) / Double(usedSpace) * 360)
    }
    
    private func endAngle(for index: Int, startAngle: Angle) -> Angle {
        let categorySize = categories[index].size
        return Angle(degrees: startAngle.degrees + Double(categorySize) / Double(usedSpace) * 360)
    }
    
    private func textPosition(for index: Int, startAngle: Angle, endAngle: Angle) -> CGPoint {
        let midAngle = Angle(degrees: (startAngle.degrees + endAngle.degrees) / 2)
        let radius: CGFloat = 80
        let centerX: CGFloat = 150
        let centerY: CGFloat = 150
        let x = centerX + radius * CGFloat(cos(midAngle.radians))
        let y = centerY + radius * CGFloat(sin(midAngle.radians))
        return CGPoint(x: x, y: y)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}