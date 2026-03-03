import SwiftUI
import FuelKit

struct WatchDashboardView: View {
    @Environment(WatchSessionManager.self) private var session

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Calorie ring
                    ZStack {
                        Circle()
                            .stroke(Color.fuelGreen.opacity(0.2), lineWidth: 10)

                        Circle()
                            .trim(from: 0, to: min(session.calorieProgress, 1.0))
                            .stroke(Color.fuelGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut, value: session.calorieProgress)

                        VStack(spacing: 0) {
                            Text("\(session.currentCalories)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("of \(session.targetCalories)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 100, height: 100)

                    // Macros
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text("\(Int(session.protein))g")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.proteinColor)
                            Text("Protein")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                        VStack(spacing: 2) {
                            Text("\(Int(session.carbs))g")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.carbsColor)
                            Text("Carbs")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                        VStack(spacing: 2) {
                            Text("\(Int(session.fat))g")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.fatColor)
                            Text("Fat")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Quick actions
                    NavigationLink {
                        WatchWaterView()
                    } label: {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(.waterBlue)
                            Text("Water: \(session.waterGlasses)/\(session.waterTarget)")
                                .font(.caption)
                        }
                    }

                    NavigationLink {
                        WatchQuickLogView()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.fuelGreen)
                            Text("Quick Log")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Fuel")
        }
    }
}
