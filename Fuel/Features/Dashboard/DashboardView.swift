import SwiftUI
import SwiftData
import FuelKit

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @State private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Date navigation
                    dateNavigator

                    // Calorie ring
                    CalorieRingView(
                        current: vm.totalCalories,
                        target: vm.targetCalories,
                        remaining: vm.caloriesRemaining
                    )

                    // Macros
                    MacroSummaryView(
                        protein: vm.totalProtein,
                        carbs: vm.totalCarbs,
                        fat: vm.totalFat,
                        targetProtein: vm.targetProtein,
                        targetCarbs: vm.targetCarbs,
                        targetFat: vm.targetFat
                    )

                    // Streak
                    if vm.streak > 0 {
                        StreakBannerView(streak: vm.streak)
                    }

                    // Quick input
                    QuickInputView()

                    // Water tracker
                    WaterTrackerView(
                        glasses: vm.waterGlasses,
                        target: vm.waterTarget,
                        onAdd: { vm.addWater(context: context, appState: appState) },
                        onRemove: { vm.removeWater(context: context) }
                    )

                    // Meal sections
                    ForEach(MealCategory.allCases) { meal in
                        MealSectionView(
                            meal: meal,
                            entries: vm.entries(for: meal),
                            totalCalories: vm.mealCalories(for: meal),
                            onDelete: { entry in vm.deleteEntry(entry, context: context) },
                            onAddTap: {
                                appState.showAddFood = true
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color.surfaceGrouped)
            .navigationTitle(vm.selectedDate.shortDisplay)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appState.showAddFood = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.fuelGreen)
                    }
                }
            }
            .onAppear {
                vm.load(context: context, appState: appState)
            }
            .onChange(of: appState.selectedDate) { _, _ in
                vm.load(context: context, appState: appState)
            }
            .refreshable {
                vm.load(context: context, appState: appState)
            }
        }
    }

    private var dateNavigator: some View {
        HStack {
            Button {
                vm.navigateDay(by: -1, appState: appState)
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(vm.selectedDate.fullDisplay)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !vm.isToday {
                    Button("Back to Today") {
                        vm.navigateDay(by: 0, appState: appState)
                        appState.selectedDate = .now.startOfDay
                        vm.load(context: context, appState: appState)
                    }
                    .font(.caption)
                }
            }

            Spacer()

            Button {
                vm.navigateDay(by: 1, appState: appState)
            } label: {
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
            }
            .disabled(vm.isToday)
        }
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView()
        .environment(try! AppState())
        .modelContainer(try! FuelModelContainer.previewContainer())
}
