import SwiftUI
import SwiftData
import FuelKit

@main
struct FuelApp: App {
    @State private var appState: AppState?
    @State private var initializationError: Error?

    init() {
        do {
            _appState = State(initialValue: try AppState())
            AppLogger.info("App initialized successfully", category: AppLogger.app)
        } catch {
            _initializationError = State(initialValue: error)
            _appState = State(initialValue: nil)
            AppLogger.critical("App initialization failed", error: error, category: AppLogger.app)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let appState {
                    ContentView()
                        .environment(appState)
                        .modelContainer(appState.modelContainer)
                        .onAppear {
                            appState.setup()
                            logAppLaunch()
                        }
                } else if let error = initializationError {
                    ErrorView(error: error)
                } else {
                    ProgressView("Loading...")
                }
            }
        }
    }
    
    private func logAppLaunch() {
        AppLogger.info("App launched - Version: \(AppConfiguration.fullVersion)", category: AppLogger.app)
        AppLogger.info("Environment: \(AppConfiguration.isProduction ? "Production" : AppConfiguration.isTestFlight ? "TestFlight" : "Debug")", category: AppLogger.app)
    }
}
private struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("Unable to Start Fuel")
                .font(.title.bold())
            
            Text("The app encountered an error while initializing:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 12) {
                Text("Try these steps:")
                    .font(.subheadline.bold())
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Restart the app", systemImage: "arrow.clockwise")
                    Label("Check available storage", systemImage: "internaldrive")
                    Label("Update to the latest iOS version", systemImage: "arrow.down.circle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button {
                // Force quit - user will need to manually restart
                fatalError("User requested app restart")
            } label: {
                Text("Restart App")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

