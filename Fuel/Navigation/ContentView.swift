import SwiftUI
import FuelKit

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
            DashboardView()
                .tabItem {
                    Label(AppState.Tab.dashboard.rawValue, systemImage: AppState.Tab.dashboard.icon)
                }
                .tag(AppState.Tab.dashboard)

            WeightView()
                .tabItem {
                    Label(AppState.Tab.weight.rawValue, systemImage: AppState.Tab.weight.icon)
                }
                .tag(AppState.Tab.weight)

            StatsView()
                .tabItem {
                    Label(AppState.Tab.stats.rawValue, systemImage: AppState.Tab.stats.icon)
                }
                .tag(AppState.Tab.stats)

            SettingsView()
                .tabItem {
                    Label(AppState.Tab.settings.rawValue, systemImage: AppState.Tab.settings.icon)
                }
                .tag(AppState.Tab.settings)
        }
        .tint(.fuelGreen)
        .sheet(isPresented: $state.showAddFood) {
            AddFoodSheet()
        }
        .fullScreenCover(isPresented: $state.showOnboarding) {
            OnboardingView()
        }
    }
}

#Preview {
    do {
        let container = try FuelModelContainer.previewContainer()
        let appState = try AppState()
        return ContentView()
            .environment(appState)
            .modelContainer(container)
    } catch {
        return Text("Preview Error: \(error.localizedDescription)")
    }
}
