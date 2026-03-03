import SwiftUI
import FuelKit

struct NLPInputView: View {
    @Bindable var vm: AddFoodViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundStyle(.fuelGreen)

                    Text("Describe what you ate")
                        .font(.headline)

                    Text("AI will estimate the nutrition info")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                // Text input
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $vm.inputText)
                        .frame(minHeight: 80, maxHeight: 120)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .overlay(alignment: .topLeading) {
                            if vm.inputText.isEmpty {
                                Text("e.g., chicken parm with a side salad and garlic bread")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .focused($isFocused)

                    // Example prompts
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            exampleChip("2 eggs and toast")
                            exampleChip("chicken caesar salad")
                            exampleChip("grande latte with oat milk")
                            exampleChip("handful of almonds")
                        }
                    }
                }

                // Parse button
                Button {
                    isFocused = false
                    Task {
                        await vm.parseFood()
                    }
                } label: {
                    HStack {
                        if vm.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(vm.isLoading ? "Analyzing..." : "Parse Food")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color.gray
                        : Color.fuelGreen,
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .foregroundStyle(.white)
                }
                .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isLoading)

                // Error message
                if let error = vm.error {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            isFocused = true
        }
    }

    private func exampleChip(_ text: String) -> some View {
        Button {
            vm.inputText = text
        } label: {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemBackground), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NLPInputView(vm: AddFoodViewModel())
}
