import SwiftUI
import SwiftData
import FuelKit

@MainActor @Observable
final class DashboardViewModel {
    var selectedDate: Date = .now.startOfDay
    var todayLog: DailyLog?
    var goals: UserGoals?
    var streak: Int = 0

    var totalCalories: Int { todayLog?.totalCalories ?? 0 }
    var targetCalories: Int { todayLog?.targetCalories ?? goals?.dailyCalories ?? 2000 }
    var caloriesRemaining: Int { targetCalories - totalCalories }
    var calorieProgress: Double { todayLog?.calorieProgress ?? 0 }

    var totalProtein: Double { todayLog?.totalProtein ?? 0 }
    var totalCarbs: Double { todayLog?.totalCarbs ?? 0 }
    var totalFat: Double { todayLog?.totalFat ?? 0 }

    var targetProtein: Double { goals?.proteinGrams ?? 150 }
    var targetCarbs: Double { goals?.carbsGrams ?? 200 }
    var targetFat: Double { goals?.fatGrams ?? 65 }

    var waterGlasses: Int { todayLog?.waterGlasses ?? 0 }
    var waterTarget: Int { goals?.waterGlasses ?? 8 }

    var isToday: Bool { selectedDate.isToday }

    func entries(for meal: MealCategory) -> [FoodEntry] {
        todayLog?.entries(for: meal) ?? []
    }

    func mealCalories(for meal: MealCategory) -> Int {
        todayLog?.mealCalories(for: meal) ?? 0
    }

    func load(context: ModelContext, appState: AppState) {
        selectedDate = appState.selectedDate
        goals = appState.currentGoals(context: context)

        let key = selectedDate.dateKey
        var descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.dateKey == key }
        )
        descriptor.fetchLimit = 1
        todayLog = try? context.fetch(descriptor).first

        streak = StreakService.calculateStreak(context: context)
    }

    func addWater(context: ModelContext, appState: AppState) {
        let log = todayLog ?? appState.ensureTodayLog(context: context)
        if log.waterGlasses < 20 {
            log.waterGlasses += 1
            todayLog = log
        }
    }

    func removeWater(context: ModelContext) {
        guard let log = todayLog, log.waterGlasses > 0 else { return }
        log.waterGlasses -= 1
    }

    func deleteEntry(_ entry: FoodEntry, context: ModelContext) {
        context.delete(entry)
    }

    func navigateDay(by offset: Int, appState: AppState) {
        let newDate = selectedDate.adding(days: offset)
        guard newDate <= Date.now.startOfDay else { return }
        selectedDate = newDate
        appState.selectedDate = newDate
    }
}
