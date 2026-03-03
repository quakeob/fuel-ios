import SwiftUI
import SwiftData
import Charts
import FuelKit

struct WeightView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WeightEntry.date, order: .reverse) private var entries: [WeightEntry]
    @State private var showAddWeight = false
    @State private var timeRange: TimeRange = .month

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case threeMonth = "90D"
    }

    var filteredEntries: [WeightEntry] {
        let cutoff: Date
        switch timeRange {
        case .week: cutoff = Date.now.daysAgo(7)
        case .month: cutoff = Date.now.daysAgo(30)
        case .threeMonth: cutoff = Date.now.daysAgo(90)
        }
        return entries.filter { $0.date >= cutoff }.reversed()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Current weight card
                    if let latest = entries.first {
                        FuelCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Weight")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text(String(format: "%.1f", latest.weight))
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                        Text(latest.unit.label)
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(latest.date.shortDisplay)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }

                                Spacer()

                                // Trend indicator
                                if entries.count >= 2 {
                                    let diff = entries[0].weight - entries[1].weight
                                    VStack(spacing: 2) {
                                        Image(systemName: diff > 0 ? "arrow.up.right" : diff < 0 ? "arrow.down.right" : "arrow.right")
                                            .font(.title2)
                                            .foregroundStyle(diff < 0 ? .fuelGreen : diff > 0 ? .fuelRed : .secondary)
                                        Text(String(format: "%+.1f", diff))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    // Chart
                    if filteredEntries.count >= 2 {
                        FuelCard {
                            VStack(alignment: .leading, spacing: 8) {
                                FuelSectionHeader(title: "Trend")

                                Picker("Range", selection: $timeRange) {
                                    ForEach(TimeRange.allCases, id: \.self) { range in
                                        Text(range.rawValue).tag(range)
                                    }
                                }
                                .pickerStyle(.segmented)

                                WeightChartView(entries: filteredEntries)
                                    .frame(height: 200)
                            }
                        }
                    }

                    // History
                    FuelCard {
                        VStack(alignment: .leading, spacing: 8) {
                            FuelSectionHeader(title: "History", icon: "list.bullet")

                            if entries.isEmpty {
                                Text("No weight entries yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .padding(.vertical)
                            } else {
                                ForEach(entries.prefix(20), id: \.id) { entry in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(String(format: "%.1f %@", entry.weight, entry.unit.label))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(entry.date.shortDisplay)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        if let note = entry.note, !note.isEmpty {
                                            Text(note)
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                                .lineLimit(1)
                                        }

                                        if entry.weightSource == .healthKit {
                                            Image(systemName: "heart.fill")
                                                .font(.caption)
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .padding(.vertical, 4)

                                    if entry.id != entries.prefix(20).last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.surfaceGrouped)
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddWeight = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.fuelGreen)
                    }
                }
            }
            .sheet(isPresented: $showAddWeight) {
                AddWeightSheet()
            }
        }
    }
}

struct WeightChartView: View {
    let entries: [WeightEntry]

    var body: some View {
        Chart(entries, id: \.id) { entry in
            LineMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .foregroundStyle(Color.fuelBlue)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [Color.fuelBlue.opacity(0.2), Color.fuelBlue.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Date", entry.date),
                y: .value("Weight", entry.weight)
            )
            .foregroundStyle(Color.fuelBlue)
            .symbolSize(20)
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: max(entries.count / 5, 1))) {
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
    }
}

struct AddWeightSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var weight = ""
    @State private var unit: WeightUnit = .lbs
    @State private var note = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    TextField("0.0", text: $weight)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .focused($focused)

                    Picker("Unit", selection: $unit) {
                        ForEach(WeightUnit.allCases, id: \.self) { u in
                            Text(u.label).tag(u)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }

                TextField("Note (optional)", text: $note)
                    .textFieldStyle(.roundedBorder)

                Button {
                    guard let value = Double(weight), value > 0 else { return }
                    let entry = WeightEntry(weight: value, unit: unit, note: note.isEmpty ? nil : note)
                    context.insert(entry)
                    dismiss()
                } label: {
                    Text("Save Weight")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.fuelGreen, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .disabled(Double(weight) == nil)

                Spacer()
            }
            .padding()
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { focused = true }
        }
    }
}

#Preview {
    WeightView()
        .modelContainer(try! FuelModelContainer.previewContainer())
}
