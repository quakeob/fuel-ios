import Foundation
import SwiftData

@Model
public final class DailyLog {
    public var id: UUID
    public var date: Date
    public var dateKey: String
    public var waterGlasses: Int
    public var targetCalories: Int
    public var targetProtein: Double
    public var targetCarbs: Double
    public var targetFat: Double

    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.dailyLog)
    public var entries: [FoodEntry]?

    public var foodEntries: [FoodEntry] {
        entries ?? []
    }

    public var totalCalories: Int {
        foodEntries.reduce(0) { $0 + $1.totalCalories }
    }

    public var totalProtein: Double {
        foodEntries.reduce(0) { $0 + $1.totalProtein }
    }

    public var totalCarbs: Double {
        foodEntries.reduce(0) { $0 + $1.totalCarbs }
    }

    public var totalFat: Double {
        foodEntries.reduce(0) { $0 + $1.totalFat }
    }

    public var caloriesRemaining: Int {
        targetCalories - totalCalories
    }

    public var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(Double(totalCalories) / Double(targetCalories), 1.5)
    }

    public func entries(for meal: MealCategory) -> [FoodEntry] {
        foodEntries
            .filter { $0.mealCategory == meal }
            .sorted { $0.createdAt < $1.createdAt }
    }

    public func mealCalories(for meal: MealCategory) -> Int {
        entries(for: meal).reduce(0) { $0 + $1.totalCalories }
    }

    public init(
        date: Date = .now,
        targetCalories: Int = 2000,
        targetProtein: Double = 150,
        targetCarbs: Double = 200,
        targetFat: Double = 65
    ) {
        self.id = UUID()
        self.date = date.startOfDay
        self.dateKey = date.dateKey
        self.waterGlasses = 0
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFat = targetFat
        self.entries = []
    }
}
