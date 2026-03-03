import SwiftUI
import FuelKit

@main
struct FuelWatchApp: App {
    @State private var sessionManager = WatchSessionManager()

    var body: some Scene {
        WindowGroup {
            WatchDashboardView()
                .environment(sessionManager)
        }
    }
}
