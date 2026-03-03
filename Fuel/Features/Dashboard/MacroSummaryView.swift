import SwiftUI
import FuelKit

struct MacroSummaryView: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    let targetProtein: Double
    let targetCarbs: Double
    let targetFat: Double

    var body: some View {
        FuelCard {
            VStack(alignment: .leading, spacing: 8) {
                FuelSectionHeader(title: "Macros", icon: "chart.pie.fill")

                MacroBarGroup(
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    targetProtein: targetProtein,
                    targetCarbs: targetCarbs,
                    targetFat: targetFat
                )

                // Macro calorie breakdown
                HStack(spacing: 0) {
                    if totalMacroCals > 0 {
                        macroSegment(label: "P", value: protein * 4, color: .proteinColor)
                        macroSegment(label: "C", value: carbs * 4, color: .carbsColor)
                        macroSegment(label: "F", value: fat * 9, color: .fatColor)
                    } else {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                    }
                }
                .frame(height: 6)
                .clipShape(Capsule())
            }
        }
    }

    private var totalMacroCals: Double {
        (protein * 4) + (carbs * 4) + (fat * 9)
    }

    @ViewBuilder
    private func macroSegment(label: String, value: Double, color: Color) -> some View {
        let fraction = totalMacroCals > 0 ? value / totalMacroCals : 0
        GeometryReader { geo in
            Rectangle()
                .fill(color)
                .frame(width: geo.size.width * fraction)
        }
    }
}

#Preview {
    MacroSummaryView(
        protein: 85,
        carbs: 120,
        fat: 45,
        targetProtein: 150,
        targetCarbs: 200,
        targetFat: 65
    )
    .padding()
}
