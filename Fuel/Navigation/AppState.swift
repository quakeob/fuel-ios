import SwiftUI
import SwiftData
import FuelKit

@Observable
final class AppState {
    var selectedTab: Tab = .dashboard
    var showAddFood = false
    var showOnboarding = false
    var selectedDate: Date = .now.startOfDay
    var cloudKitEnabled = false

    private(set) var modelContainer: ModelContainer

    enum Tab: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case weight = "Weight"
        case stats = "Stats"
        case settings = "Settings"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .dashboard: return "flame.fill"
            case .weight: return "scalemass.fill"
            case .stats: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    init() throws {
        modelContainer = try FuelModelContainer.create()
    }

    @MainActor func setup() {
        let context = modelContainer.mainContext
        do {
            let descriptor = FetchDescriptor<UserGoals>()
            let goals = try context.fetch(descriptor)
            if goals.isEmpty {
                showOnboarding = true
                AppLogger.info("No user goals found, showing onboarding", category: AppLogger.app)
            } else {
                AppLogger.info("User goals loaded successfully", category: AppLogger.data)
            }
        } catch {
            AppLogger.error("Failed to fetch user goals during setup", error: error, category: AppLogger.data)
            // Show onboarding as fallback
            showOnboarding = true
        }
    }

    @MainActor
    func ensureTodayLog(context: ModelContext) -> DailyLog {
        let todayKey = Date.now.dateKey
        var descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.dateKey == todayKey }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                return existing
            }
        } catch {
            AppLogger.error("Error fetching today's log", error: error, category: AppLogger.data)
        }

        let goals = currentGoals(context: context)
        let log = DailyLog(
            date: .now,
            targetCalories: goals.dailyCalories,
            targetProtein: goals.proteinGrams,
            targetCarbs: goals.carbsGrams,
            targetFat: goals.fatGrams
        )
        context.insert(log)
        
        // Save the context to ensure persistence
        do {
            try context.save()
            AppLogger.info("Created new daily log for today", category: AppLogger.data)
        } catch {
            AppLogger.error("Error saving new daily log", error: error, category: AppLogger.data)
        }
        
        return log
    }

    @MainActor
    func currentGoals(context: ModelContext) -> UserGoals {
        do {
            let descriptor = FetchDescriptor<UserGoals>()
            if let goals = try context.fetch(descriptor).first {
                return goals
            }
        } catch {
            AppLogger.error("Error fetching user goals", error: error, category: AppLogger.data)
        }
        
        let defaults = UserGoals.defaults
        context.insert(defaults)
        
        do {
            try context.save()
            AppLogger.info("Created default user goals", category: AppLogger.data)
        } catch {
            AppLogger.error("Error saving default goals", error: error, category: AppLogger.data)
        }
        
        return defaults
    }

    func logForDate(_ date: Date, context: ModelContext) -> DailyLog? {
        let key = date.dateKey
        var descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.dateKey == key }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
}
