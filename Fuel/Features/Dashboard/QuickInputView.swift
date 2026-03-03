import SwiftUI
import FuelKit

struct QuickInputView: View {
    @Environment(AppState.self) private var appState
    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.subheadline)
                .foregroundStyle(.fuelGreen)

            TextField("What did you eat?", text: $inputText)
                .font(.subheadline)
                .focused($isFocused)
                .submitLabel(.go)
                .onSubmit {
                    submitInput()
                }

            if !inputText.isEmpty {
                Button {
                    submitInput()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.fuelGreen)
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func submitInput() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        appState.showAddFood = true
        isFocused = false
        // Text will be passed through to AddFoodSheet
        inputText = ""
    }
}

#Preview {
    QuickInputView()
        .environment(try! AppState())
        .padding()
}
