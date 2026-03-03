import SwiftUI
import FuelKit

struct MacroProgressBar: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color
    let unit: String

    @State private var animatedProgress: Double = 0

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(current))/\(Int(target))\(unit)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(current > target ? .red : .primary)
                    .contentTransition(.numericText())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(color.opacity(0.15))

                    // Fill
                    Capsule()
                        .fill(
                            current > target
                            ? AnyShapeStyle(Color.fuelRed)
                            : AnyShapeStyle(color)
                        )
                        .frame(width: max(0, geo.size.width * min(animatedProgress, 1.0)))
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.4)) {
                animatedProgress = newValue
            }
        }
    }
}

struct MacroBarGroup: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    let targetProtein: Double
    let targetCarbs: Double
    let targetFat: Double

    var body: some View {
        VStack(spacing: 10) {
            MacroProgressBar(
                label: "Protein",
                current: protein,
                target: targetProtein,
                color: .proteinColor,
                unit: "g"
            )
            MacroProgressBar(
                label: "Carbs",
                current: carbs,
                target: targetCarbs,
                color: .carbsColor,
                unit: "g"
            )
            MacroProgressBar(
                label: "Fat",
                current: fat,
                target: targetFat,
                color: .fatColor,
                unit: "g"
            )
        }
    }
}

#Preview {
    MacroBarGroup(
        protein: 85,
        carbs: 120,
        fat: 45,
        targetProtein: 150,
        targetCarbs: 200,
        targetFat: 65
    )
    .padding()
}
