import XCTest
import SwiftData
@testable import FuelKit

final class FuelModelTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!

    @MainActor
    override func setUp() {
        super.setUp()
        container = try! FuelModelContainer.previewContainer()
        context = container.mainContext
    }

    // MARK: - FoodEntry Tests

    @MainActor
    func testFoodEntryCreation() throws {
        let entry = FoodEntry(
            name: "Chicken Breast",
            emoji: "🍗",
            calories: 165,
            protein: 31,
            carbs: 0,
            fat: 3.6,
            mealCategory: .lunch
        )
        context.insert(entry)

        let descriptor = FetchDescriptor<FoodEntry>()
        let entries = try context.fetch(descriptor)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.name, "Chicken Breast")
        XCTAssertEqual(entries.first?.calories, 165)
        XCTAssertEqual(entries.first?.mealCategory, .lunch)
    }

    @MainActor
    func testFoodEntryTotalCaloriesWithQuantity() {
        let entry = FoodEntry(
            name: "Egg",
            calories: 72,
            protein: 6.3,
            carbs: 0.4,
            fat: 4.8
        )
        entry.quantity = 3
        XCTAssertEqual(entry.totalCalories, 216)
        XCTAssertEqual(entry.totalProtein, 18.9, accuracy: 0.1)
    }

    // MARK: - DailyLog Tests

    @MainActor
    func testDailyLogTotals() throws {
        let log = DailyLog(date: .now, targetCalories: 2000, targetProtein: 150, targetCarbs: 200, targetFat: 65)
        context.insert(log)

        let entry1 = FoodEntry(name: "Eggs", calories: 220, protein: 16, carbs: 2, fat: 16, mealCategory: .breakfast)
        let entry2 = FoodEntry(name: "Chicken", calories: 380, protein: 35, carbs: 12, fat: 18, mealCategory: .lunch)
        context.insert(entry1)
        context.insert(entry2)
        entry1.dailyLog = log
        entry2.dailyLog = log

        XCTAssertEqual(log.totalCalories, 600)
        XCTAssertEqual(log.totalProtein, 51, accuracy: 0.1)
        XCTAssertEqual(log.caloriesRemaining, 1400)
    }

    @MainActor
    func testDailyLogMealCategoryFilter() throws {
        let log = DailyLog(date: .now)
        context.insert(log)

        let breakfast = FoodEntry(name: "Toast", calories: 180, mealCategory: .breakfast)
        let lunch = FoodEntry(name: "Salad", calories: 300, mealCategory: .lunch)
        context.insert(breakfast)
        context.insert(lunch)
        breakfast.dailyLog = log
        lunch.dailyLog = log

        XCTAssertEqual(log.entries(for: .breakfast).count, 1)
        XCTAssertEqual(log.entries(for: .lunch).count, 1)
        XCTAssertEqual(log.entries(for: .dinner).count, 0)
        XCTAssertEqual(log.mealCalories(for: .breakfast), 180)
    }

    // MARK: - WeightEntry Tests

    @MainActor
    func testWeightConversion() {
        let entry = WeightEntry(weight: 180, unit: .lbs)
        let kg = entry.weight(in: .kg)
        XCTAssertEqual(kg, 81.6, accuracy: 0.1)
    }

    // MARK: - UserGoals Tests

    @MainActor
    func testDefaultGoals() {
        let goals = UserGoals.defaults
        XCTAssertEqual(goals.dailyCalories, 2000)
        XCTAssertEqual(goals.proteinGrams, 150)
        XCTAssertEqual(goals.waterGlasses, 8)
    }

    // MARK: - FoodTemplate Tests

    @MainActor
    func testTemplateFromEntry() {
        let entry = FoodEntry(
            name: "Greek Yogurt",
            emoji: "🫙",
            calories: 100,
            protein: 17,
            carbs: 6,
            fat: 0.7
        )
        let template = FoodTemplate.from(entry)
        XCTAssertEqual(template.name, "Greek Yogurt")
        XCTAssertEqual(template.calories, 100)

        template.recordUsage()
        XCTAssertEqual(template.usageCount, 1)

        let newEntry = template.toFoodEntry(meal: .snacks)
        XCTAssertEqual(newEntry.name, "Greek Yogurt")
        XCTAssertEqual(newEntry.source, .template)
        XCTAssertEqual(newEntry.mealCategory, .snacks)
    }

    // MARK: - EmojiMapper Tests

    func testEmojiMapping() {
        XCTAssertEqual(EmojiMapper.emoji(for: "Chicken Breast"), "🍗")
        XCTAssertEqual(EmojiMapper.emoji(for: "Banana"), "🍌")
        XCTAssertEqual(EmojiMapper.emoji(for: "Coffee Black"), "☕")
        XCTAssertEqual(EmojiMapper.emoji(for: "Pizza Margherita"), "🍕")
        XCTAssertEqual(EmojiMapper.emoji(for: "Unknown Food XYZ"), "🍽️")
    }

    // MARK: - Date Helpers Tests

    func testDateKey() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "2026-02-11")!
        XCTAssertEqual(date.dateKey, "2026-02-11")
    }

    func testDateFromKey() {
        let date = Date.fromKey("2026-02-11")
        XCTAssertNotNil(date)
        XCTAssertEqual(date?.dateKey, "2026-02-11")
    }
}

final class FoodParsingTests: XCTestCase {

    func testParsedFoodToEntry() {
        let parsed = ParsedFood(
            name: "Grilled Chicken",
            calories: 250,
            protein: 38,
            carbs: 0,
            fat: 10,
            fiber: 0,
            servingSize: "1 breast",
            servingGrams: 170,
            quantity: 1,
            confidence: 0.9
        )

        let entry = parsed.toFoodEntry(meal: .dinner, originalInput: "grilled chicken breast")
        XCTAssertEqual(entry.name, "Grilled Chicken")
        XCTAssertEqual(entry.calories, 250)
        XCTAssertEqual(entry.source, .ai)
        XCTAssertEqual(entry.mealCategory, .dinner)
        XCTAssertEqual(entry.originalInput, "grilled chicken breast")
    }

    func testOfflineFoodDBSearch() {
        let results = OfflineFoodDB.shared.search("chicken breast")
        // Should find "Chicken Breast" from our USDA sqlite DB
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.first?.name.lowercased().contains("chicken") ?? false)
    }
}
