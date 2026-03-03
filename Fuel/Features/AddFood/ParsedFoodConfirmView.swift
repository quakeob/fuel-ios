import SwiftUI
import FuelKit

struct ParsedFoodConfirmView: View {
    @Bindable var vm: AddFoodViewModel
    var onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var totalCalories: Int {
        vm.parsedFoods.reduce(0) { $0 + $1.calories * $1.quantity }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary header
                    VStack(spacing: 4) {
                        Text("\(vm.parsedFoods.count) item\(vm.parsedFoods.count == 1 ? "" : "s") found")
                            .font(.headline)
                        Text("\(totalCalories) cal total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)

                    // Food items
                    ForEach($vm.parsedFoods) { $food in
                        parsedFoodCard(food: $food)
                    }

                    // Meal selector
                    HStack {
                        Text("Log to:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Picker("Meal", selection: $vm.selectedMeal) {
                            ForEach(MealCategory.allCases) { meal in
                                Text("\(meal.emoji) \(meal.rawValue)")
                                    .tag(meal)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal)

                    // Confidence note
                    if vm.parsedFoods.contains(where: { $0.confidence < 0.7 }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.orange)
                            Text("Some items have low confidence. Tap to edit.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .navigationTitle("Confirm Foods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log All") {
                        onConfirm()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.fuelGreen)
                }
            }
        }
    }

    private func parsedFoodCard(food: Binding<ParsedFood>) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(EmojiMapper.emoji(for: food.wrappedValue.name))
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(food.wrappedValue.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(food.wrappedValue.servingSize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(food.wrappedValue.calories * food.wrappedValue.quantity)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("cal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Macro row
            HStack(spacing: 16) {
                macroChip("P", value: food.wrappedValue.protein, color: .proteinColor)
                macroChip("C", value: food.wrappedValue.carbs, color: .carbsColor)
                macroChip("F", value: food.wrappedValue.fat, color: .fatColor)

                Spacer()

                // Quantity stepper
                HStack(spacing: 8) {
                    Button {
                        if food.wrappedValue.quantity > 1 {
                            food.wrappedValue.quantity -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle")
                            .foregroundStyle(.secondary)
                    }

                    Text("x\(food.wrappedValue.quantity)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(minWidth: 24)

                    Button {
                        food.wrappedValue.quantity += 1
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.fuelGreen)
                    }
                }
            }

            // Confidence bar
            if food.wrappedValue.confidence < 1.0 {
                HStack(spacing: 4) {
                    Image(systemName: confidenceIcon(food.wrappedValue.confidence))
                        .font(.caption2)
                        .foregroundStyle(confidenceColor(food.wrappedValue.confidence))
                    Text("\(Int(food.wrappedValue.confidence * 100))% confidence")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func macroChip(_ label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text("\(Int(value))g")
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1), in: Capsule())
    }

    private func confidenceIcon(_ confidence: Double) -> String {
        if confidence >= 0.8 { return "checkmark.circle.fill" }
        if confidence >= 0.6 { return "exclamationmark.circle.fill" }
        return "questionmark.circle.fill"
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        if confidence >= 0.6 { return .orange }
        return .red
    }
}

#Preview {
    let vm = AddFoodViewModel()
    vm.parsedFoods = [
        ParsedFood(name: "Chicken Parmesan", calories: 430, protein: 38, carbs: 22, fat: 20, fiber: 2, servingSize: "1 piece", servingGrams: 280, quantity: 1, confidence: 0.85),
        ParsedFood(name: "Side Salad", calories: 80, protein: 3, carbs: 8, fat: 4, fiber: 3, servingSize: "1 bowl", servingGrams: 150, quantity: 1, confidence: 0.9),
    ]

    return ParsedFoodConfirmView(vm: vm) {}
}
