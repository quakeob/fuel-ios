import SwiftUI
import FuelKit

struct CalorieRingView: View {
    let current: Int
    let target: Int
    let remaining: Int

    var body: some View {
        FuelCard {
            VStack(spacing: 12) {
                AnimatedRingWithLabel(
                    current: current,
                    target: target,
                    unit: "cal",
                    lineWidth: 18,
                    size: 180
                )

                HStack(spacing: 24) {
                    CalorieStat(label: "Eaten", value: current, color: .fuelGreen)
                    CalorieStat(label: "Remaining", value: max(remaining, 0), color: remaining >= 0 ? .primary : .fuelRed)
                    CalorieStat(label: "Target", value: target, color: .secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct CalorieStat: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack {
        CalorieRingView(current: 1450, target: 2000, remaining: 550)
        CalorieRingView(current: 2200, target: 2000, remaining: -200)
    }
    .padding()
}
