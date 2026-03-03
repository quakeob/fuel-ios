import SwiftUI
import FuelKit

struct ManualEntryView: View {
    @Bindable var vm: AddFoodViewModel
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name, calories, protein, carbs, fat, fiber
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Food name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Food Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    TextField("e.g., Grilled Chicken", text: $vm.manualName)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .name)
                }

                // Calories (large, prominent)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Calories")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    TextField("0", text: $vm.manualCalories)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .calories)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }

                // Macros grid
                VStack(alignment: .leading, spacing: 6) {
                    Text("Macros (optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        macroField("Protein", text: $vm.manualProtein, color: .proteinColor, field: .protein)
                        macroField("Carbs", text: $vm.manualCarbs, color: .carbsColor, field: .carbs)
                        macroField("Fat", text: $vm.manualFat, color: .fatColor, field: .fat)
                    }
                }

                // Serving description
                VStack(alignment: .leading, spacing: 6) {
                    Text("Serving Size")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    TextField("1 serving", text: $vm.manualServing)
                        .textFieldStyle(.roundedBorder)
                }

                // Log button
                Button {
                    vm.logManualEntry(context: context, appState: appState)
                    dismiss()
                } label: {
                    Text("Log Food")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            canLog ? Color.fuelGreen : Color.gray,
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .foregroundStyle(.white)
                }
                .disabled(!canLog)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            focusedField = .name
        }
    }

    private var canLog: Bool {
        !vm.manualCalories.isEmpty && (Int(vm.manualCalories) ?? 0) > 0
    }

    private func macroField(_ label: String, text: Binding<String>, color: Color, field: Field) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
                .fontWeight(.medium)

            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: field)
                .padding(8)
                .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                )

            Text("g")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ManualEntryView(vm: AddFoodViewModel())
        .environment(try! AppState())
        .modelContainer(try! FuelModelContainer.previewContainer())
}
