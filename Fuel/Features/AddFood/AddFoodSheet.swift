import SwiftUI
import SwiftData
import FuelKit

struct AddFoodSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = AddFoodViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Meal picker
                mealPicker

                // Tab selector
                tabSelector

                // Tab content
                TabView(selection: $vm.selectedTab) {
                    NLPInputView(vm: vm)
                        .tag(AddFoodViewModel.AddFoodTab.ai)

                    ManualEntryView(vm: vm)
                        .tag(AddFoodViewModel.AddFoodTab.manual)

                    recentFoodsView
                        .tag(AddFoodViewModel.AddFoodTab.recent)

                    ScannerView(vm: vm)
                        .tag(AddFoodViewModel.AddFoodTab.scan)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                vm.detectMealFromTime()
                vm.loadRecents(context: context)
            }
            .sheet(isPresented: $vm.showConfirmation) {
                ParsedFoodConfirmView(vm: vm) {
                    vm.logParsedFoods(context: context, appState: appState)
                    dismiss()
                }
            }
        }
    }

    private var mealPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MealCategory.allCases) { meal in
                    Button {
                        vm.selectedMeal = meal
                    } label: {
                        HStack(spacing: 4) {
                            Text(meal.emoji)
                                .font(.caption)
                            Text(meal.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            vm.selectedMeal == meal
                            ? Color.mealColor(for: meal).opacity(0.2)
                            : Color.clear,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    vm.selectedMeal == meal
                                    ? Color.mealColor(for: meal)
                                    : Color.gray.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(AddFoodViewModel.AddFoodTab.allCases) { tab in
                Button {
                    withAnimation {
                        vm.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.subheadline)
                        Text(tab.rawValue)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(vm.selectedTab == tab ? Color.fuelGreen : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var recentFoodsView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if vm.recentTemplates.isEmpty {
                    ContentUnavailableView(
                        "No Recent Foods",
                        systemImage: "clock",
                        description: Text("Foods you log will appear here for quick re-logging")
                    )
                } else {
                    ForEach(vm.recentTemplates, id: \.id) { template in
                        Button {
                            vm.logTemplate(template, context: context, appState: appState)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text(template.emoji)
                                    .font(.title2)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(template.servingDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(template.calories)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("cal")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    AddFoodSheet()
        .environment(try! AppState())
        .modelContainer(try! FuelModelContainer.previewContainer())
}
