import SwiftUI
import FuelKit

struct ScannerView: View {
    @Bindable var vm: AddFoodViewModel
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            if let product = vm.scannedProduct {
                // Show scanned product
                scannedProductView(product)
            } else if vm.isLoading {
                Spacer()
                ProgressView("Looking up barcode...")
                Spacer()
            } else if let error = vm.error {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Try Again") {
                        vm.error = nil
                        vm.scannedBarcode = nil
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
            } else {
                // Camera view
                BarcodeCameraView { barcode in
                    Task {
                        await vm.lookupBarcode(barcode)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()

                Text("Point camera at a barcode")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Manual barcode entry
                HStack {
                    TextField("Or enter barcode manually", text: Binding(
                        get: { vm.scannedBarcode ?? "" },
                        set: { vm.scannedBarcode = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                    Button("Look Up") {
                        if let barcode = vm.scannedBarcode, !barcode.isEmpty {
                            Task {
                                await vm.lookupBarcode(barcode)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
        }
    }

    private func scannedProductView(_ product: ParsedFood) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Product info
                VStack(spacing: 8) {
                    Text(EmojiMapper.emoji(for: product.name))
                        .font(.system(size: 48))

                    Text(product.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(product.servingSize)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                // Calories
                VStack(spacing: 2) {
                    Text("\(product.calories)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("calories")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Macros
                HStack(spacing: 20) {
                    macroDisplay("Protein", value: product.protein, color: .proteinColor)
                    macroDisplay("Carbs", value: product.carbs, color: .carbsColor)
                    macroDisplay("Fat", value: product.fat, color: .fatColor)
                    macroDisplay("Fiber", value: product.fiber, color: .fiberColor)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                // Log button
                Button {
                    vm.logScannedProduct(context: context, appState: appState)
                    dismiss()
                } label: {
                    Text("Log \(product.name)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.fuelGreen, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }

                // Scan another
                Button {
                    vm.scannedProduct = nil
                    vm.scannedBarcode = nil
                } label: {
                    Text("Scan Another")
                        .font(.subheadline)
                }
            }
            .padding()
        }
    }

    private func macroDisplay(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(value))g")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScannerView(vm: AddFoodViewModel())
        .environment(try! AppState())
        .modelContainer(try! FuelModelContainer.previewContainer())
}
