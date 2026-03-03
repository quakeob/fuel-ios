import Foundation
import SwiftData

public enum FuelModelContainer {
    public static let appGroupIdentifier = AppConfiguration.appGroupIdentifier

    public static var schema: Schema {
        Schema([
            FoodEntry.self,
            DailyLog.self,
            WeightEntry.self,
            UserGoals.self,
            FoodTemplate.self
        ])
    }

    public static func create(cloudKit: Bool = AppConfiguration.Features.cloudKitEnabled) throws -> ModelContainer {
        let config: ModelConfiguration
        if cloudKit {
            config = ModelConfiguration(
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .automatic
            )
        } else {
            config = ModelConfiguration(
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .none
            )
        }
        return try ModelContainer(for: schema, configurations: [config])
    }

    public static var storeURL: URL {
        if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            return containerURL.appendingPathComponent(AppConfiguration.Storage.storeFilename)
        }
        // Fallback for development/previews
        return URL.applicationSupportDirectory.appendingPathComponent(AppConfiguration.Storage.storeFilename)
    }

    public static func previewContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(for: schema, configurations: [config])
        return container
    }

    @MainActor
    public static func previewContainerWithSampleData() throws -> ModelContainer {
        let container = try previewContainer()
        let context = container.mainContext

        let goals = UserGoals(
            dailyCalories: 2000,
            proteinGrams: 150,
            carbsGrams: 200,
            fatGrams: 65,
            waterGlasses: 8
        )
        context.insert(goals)

        let log = DailyLog(
            date: .now,
            targetCalories: goals.dailyCalories,
            targetProtein: goals.proteinGrams,
            targetCarbs: goals.carbsGrams,
            targetFat: goals.fatGrams
        )
        context.insert(log)

        let sampleFoods: [(String, String, Int, Double, Double, Double, MealCategory)] = [
            ("Scrambled Eggs", "🥚", 220, 16, 2, 16, .breakfast),
            ("Toast with Butter", "🍞", 180, 4, 24, 8, .breakfast),
            ("Grilled Chicken Salad", "🥗", 380, 35, 12, 18, .lunch),
            ("Greek Yogurt", "🫙", 150, 15, 12, 5, .snacks),
        ]

        for (name, emoji, cal, protein, carbs, fat, meal) in sampleFoods {
            let entry = FoodEntry(
                name: name,
                emoji: emoji,
                calories: cal,
                protein: protein,
                carbs: carbs,
                fat: fat,
                mealCategory: meal
            )
            context.insert(entry)
            entry.dailyLog = log
        }

        log.waterGlasses = 4

        return container
    }
}
