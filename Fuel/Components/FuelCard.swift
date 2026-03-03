import SwiftUI
import FuelKit

struct FuelCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct FuelSectionHeader: View {
    let title: String
    var icon: String? = nil
    var trailing: (() -> AnyView)? = nil

    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            if let trailing {
                trailing()
            }
        }
    }
}

struct FoodItemRow: View {
    let entry: FoodEntry
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Text(entry.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(entry.servingDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if entry.quantity != 1 {
                        Text("x\(entry.quantity, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.totalCalories)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("cal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack {
        FuelCard {
            VStack(alignment: .leading) {
                FuelSectionHeader(title: "Lunch", icon: "sun.max.fill")
                FoodItemRow(entry: {
                    let e = FoodEntry(
                        name: "Grilled Chicken Salad",
                        emoji: "🥗",
                        calories: 380,
                        protein: 35,
                        carbs: 12,
                        fat: 18,
                        mealCategory: .lunch
                    )
                    return e
                }())
            }
        }
    }
    .padding()
}
