import SwiftUI
import FuelKit

struct MealSectionView: View {
    let meal: MealCategory
    let entries: [FoodEntry]
    let totalCalories: Int
    var onDelete: ((FoodEntry) -> Void)? = nil
    var onAddTap: (() -> Void)? = nil

    var body: some View {
        FuelCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(meal.emoji)
                        .font(.title3)
                    Text(meal.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    if totalCalories > 0 {
                        Text("\(totalCalories) cal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        onAddTap?()
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundStyle(.fuelGreen)
                    }
                }

                if entries.isEmpty {
                    Text("No foods logged")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(entries, id: \.id) { entry in
                        FoodItemRow(entry: entry)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        onDelete?(entry)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }

                        if entry.id != entries.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let entries = [
        FoodEntry(name: "Scrambled Eggs", emoji: "🥚", calories: 220, protein: 16, carbs: 2, fat: 16, mealCategory: .breakfast),
        FoodEntry(name: "Toast with Butter", emoji: "🍞", calories: 180, protein: 4, carbs: 24, fat: 8, mealCategory: .breakfast)
    ]

    VStack {
        MealSectionView(meal: .breakfast, entries: entries, totalCalories: 400)
        MealSectionView(meal: .lunch, entries: [], totalCalories: 0)
    }
    .padding()
}
