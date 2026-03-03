import SwiftUI
import SwiftData
import Charts
import FuelKit

struct StatsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var timeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
    }

    var filteredLogs: [DailyLog] {
        let days = timeRange == .week ? 7 : 30
        let cutoff = Date.now.daysAgo(days)
        return logs.filter { $0.date >= cutoff }.reversed()
    }

    var averageCalories: Int {
        guard !filteredLogs.isEmpty else { return 0 }
        return filteredLogs.reduce(0) { $0 + $1.totalCalories } / filteredLogs.count
    }

    var averageProtein: Int {
        guard !filteredLogs.isEmpty else { return 0 }
        return Int(filteredLogs.reduce(0.0) { $0 + $1.totalProtein } / Double(filteredLogs.count))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Averages
                    HStack(spacing: 12) {
                        StatCard(title: "Avg Calories", value: "\(averageCalories)", subtitle: "cal/day", color: .fuelGreen)
                        StatCard(title: "Avg Protein", value: "\(averageProtein)g", subtitle: "per day", color: .proteinColor)
                    }
                    .padding(.horizontal)

                    // Calorie trend chart
                    FuelCard {
                        VStack(alignment: .leading, spacing: 8) {
                            FuelSectionHeader(title: "Calorie Trend", icon: "flame.fill")

                            if filteredLogs.count >= 2 {
                                Chart(filteredLogs, id: \.id) { log in
                                    BarMark(
                                        x: .value("Date", log.date, unit: .day),
                                        y: .value("Calories", log.totalCalories)
                                    )
                                    .foregroundStyle(
                                        log.totalCalories > log.targetCalories
                                        ? Color.fuelRed.opacity(0.7)
                                        : Color.fuelGreen.opacity(0.7)
                                    )
                                    .cornerRadius(4)

                                    if log.targetCalories > 0 {
                                        RuleMark(y: .value("Target", log.targetCalories))
                                            .foregroundStyle(.gray.opacity(0.5))
                                            .lineStyle(StrokeStyle(dash: [5, 5]))
                                    }
                                }
                                .frame(height: 200)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) {
                                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                    }
                                }
                            } else {
                                Text("Log at least 2 days to see trends")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Macro trend
                    FuelCard {
                        VStack(alignment: .leading, spacing: 8) {
                            FuelSectionHeader(title: "Macro Breakdown", icon: "chart.pie.fill")

                            if filteredLogs.count >= 2 {
                                Chart(filteredLogs, id: \.id) { log in
                                    BarMark(
                                        x: .value("Date", log.date, unit: .day),
                                        y: .value("Grams", log.totalProtein)
                                    )
                                    .foregroundStyle(by: .value("Macro", "Protein"))

                                    BarMark(
                                        x: .value("Date", log.date, unit: .day),
                                        y: .value("Grams", log.totalCarbs)
                                    )
                                    .foregroundStyle(by: .value("Macro", "Carbs"))

                                    BarMark(
                                        x: .value("Date", log.date, unit: .day),
                                        y: .value("Grams", log.totalFat)
                                    )
                                    .foregroundStyle(by: .value("Macro", "Fat"))
                                }
                                .chartForegroundStyleScale([
                                    "Protein": Color.proteinColor,
                                    "Carbs": Color.carbsColor,
                                    "Fat": Color.fatColor
                                ])
                                .frame(height: 200)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) {
                                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                    }
                                }
                            } else {
                                Text("Log at least 2 days to see trends")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.surfaceGrouped)
            .navigationTitle("Stats")
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatsView()
        .modelContainer(try! FuelModelContainer.previewContainer())
}
