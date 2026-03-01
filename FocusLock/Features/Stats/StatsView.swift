import SwiftUI
import Charts

struct StatsView: View {
    // Mock data for charts
    private let weeklyData: [(day: String, hours: Double)] = [
        ("Mon", 3.2), ("Tue", 2.8), ("Wed", 4.1),
        ("Thu", 1.5), ("Fri", 3.7), ("Sat", 0.8), ("Sun", 1.2)
    ]
    
    private let heatmapData: [[Double]] = [
        [0, 1, 2, 3, 1, 0, 2, 3, 2, 1, 0, 1],
        [1, 2, 3, 2, 0, 1, 2, 3, 1, 0, 2, 3],
        [2, 3, 1, 0, 2, 3, 1, 2, 3, 2, 1, 0],
        [0, 1, 3, 2, 1, 0, 3, 2, 1, 3, 2, 1],
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("Focus Stats")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Track your progress")
                        .font(.system(size: 14))
                        .foregroundStyle(FLColor.cyan)
                }
                .padding(.top, 16)
                
                // Weekly Bar Chart
                weeklyChart
                
                // Stat Cards 2x2
                statCardsGrid
                
                // Native Ad
                NativeAdView()
                
                // Heatmap
                heatmapSection
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
        .focusLockBackground()
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            
            Chart {
                ForEach(weeklyData, id: \.day) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [FLColor.cyan, FLColor.purple],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let day = value.as(String.self) {
                            Text(day)
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            .frame(height: 180)
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - Stat Cards
    
    private var statCardsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            statCard(icon: "flame.fill", iconColor: .orange, value: "7", label: "Day Streak")
            statCard(icon: "clock.fill", iconColor: FLColor.cyan, value: "17.3h", label: "Total Focus")
            statCard(icon: "lock.fill", iconColor: FLColor.dangerRed, value: "23", label: "Apps Blocked")
            statCard(icon: "checkmark.circle.fill", iconColor: FLColor.neonGreen, value: "68%", label: "Give Up Rate")
        }
    }
    
    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassCard()
    }
    
    // MARK: - Heatmap
    
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Heatmap")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            
            VStack(spacing: 3) {
                ForEach(0..<heatmapData.count, id: \.self) { row in
                    HStack(spacing: 3) {
                        ForEach(0..<heatmapData[row].count, id: \.self) { col in
                            let intensity = heatmapData[row][col]
                            RoundedRectangle(cornerRadius: 3)
                                .fill(heatmapColor(intensity: intensity))
                                .frame(height: 18)
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 4) {
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
                
                ForEach([0.0, 1.0, 2.0, 3.0], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(heatmapColor(intensity: level))
                        .frame(width: 12, height: 12)
                }
                
                Text("More")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .glassCard()
    }
    
    private func heatmapColor(intensity: Double) -> Color {
        switch intensity {
        case 0: return Color.white.opacity(0.05)
        case 1: return FLColor.purple.opacity(0.3)
        case 2: return FLColor.purple.opacity(0.6)
        default: return FLColor.cyan.opacity(0.8)
        }
    }
}

#Preview {
    StatsView()
}
