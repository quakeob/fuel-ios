import WidgetKit
import SwiftUI
import SwiftData
import FuelKit

struct CalorieProgressWidget: Widget {
    let kind = "CalorieProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalorieTimelineProvider()) { entry in
            CalorieWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calorie Progress")
        .description("Track your daily calorie intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Entry

struct CalorieEntry: TimelineEntry {
    let date: Date
    let currentCalories: Int
    let targetCalories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let waterGlasses: Int
    let waterTarget: Int

    var progress: Double {
        guard targetCalories > 0 else { return 0 }
        return Double(currentCalories) / Double(targetCalories)
    }

    var remaining: Int {
        targetCalories - currentCalories
    }

    static var placeholder: CalorieEntry {
        CalorieEntry(
            date: .now,
            currentCalories: 1200,
            targetCalories: 2000,
            protein: 85,
            carbs: 120,
            fat: 45,
            waterGlasses: 4,
            waterTarget: 8
        )
    }
}

// MARK: - Timeline Provider

struct CalorieTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalorieEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (CalorieEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalorieEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> CalorieEntry {
        do {
            let container = try FuelModelContainer.create()
            let context = ModelContext(container)

            let todayKey = Date.now.dateKey
            var descriptor = FetchDescriptor<DailyLog>(
                predicate: #Predicate { $0.dateKey == todayKey }
            )
            descriptor.fetchLimit = 1

            if let log = try context.fetch(descriptor).first {
                return CalorieEntry(
                    date: .now,
                    currentCalories: log.totalCalories,
                    targetCalories: log.targetCalories,
                    protein: log.totalProtein,
                    carbs: log.totalCarbs,
                    fat: log.totalFat,
                    waterGlasses: log.waterGlasses,
                    waterTarget: 8
                )
            }
        } catch {
            // Fall through to placeholder
        }

        return .placeholder
    }
}

// MARK: - Widget Views

struct CalorieWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CalorieEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.fuelGreen.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: min(entry.progress, 1.0))
                    .stroke(Color.fuelGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(entry.currentCalories)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("cal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 80, height: 80)

            Text("\(max(entry.remaining, 0)) left")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            // Ring
            ZStack {
                Circle()
                    .stroke(Color.fuelGreen.opacity(0.2), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: min(entry.progress, 1.0))
                    .stroke(Color.fuelGreen, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(entry.currentCalories)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("of \(entry.targetCalories)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)

            // Macros
            VStack(alignment: .leading, spacing: 8) {
                Text("Fuel")
                    .font(.headline)
                    .fontWeight(.bold)

                macroRow("Protein", value: Int(entry.protein), color: .proteinColor)
                macroRow("Carbs", value: Int(entry.carbs), color: .carbsColor)
                macroRow("Fat", value: Int(entry.fat), color: .fatColor)

                HStack(spacing: 2) {
                    ForEach(0..<entry.waterTarget, id: \.self) { i in
                        Image(systemName: i < entry.waterGlasses ? "drop.fill" : "drop")
                            .font(.caption2)
                            .foregroundStyle(i < entry.waterGlasses ? Color.waterBlue : .gray.opacity(0.3))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func macroRow(_ label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(label): \(value)g")
                .font(.caption)
        }
    }
}

#Preview(as: .systemSmall) {
    CalorieProgressWidget()
} timeline: {
    CalorieEntry.placeholder
}

#Preview(as: .systemMedium) {
    CalorieProgressWidget()
} timeline: {
    CalorieEntry.placeholder
}
