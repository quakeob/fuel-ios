import Foundation
import SwiftData

@Model
public final class FoodTemplate {
    public var id: UUID
    public var name: String
    public var emoji: String
    public var calories: Int
    public var protein: Double
    public var carbs: Double
    public var fat: Double
    public var fiber: Double
    public var servingDescription: String
    public var servingGrams: Double
    public var barcode: String?
    public var usageCount: Int
    public var lastUsed: Date
    public var createdAt: Date

    public init(
        name: String = "",
        emoji: String = "🍽️",
        calories: Int = 0,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        fiber: Double = 0,
        servingDescription: String = "1 serving",
        servingGrams: Double = 100,
        barcode: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.servingDescription = servingDescription
        self.servingGrams = servingGrams
        self.barcode = barcode
        self.usageCount = 0
        self.lastUsed = Date()
        self.createdAt = Date()
    }

    public static func from(_ entry: FoodEntry) -> FoodTemplate {
        FoodTemplate(
            name: entry.name,
            emoji: entry.emoji,
            calories: entry.calories,
            protein: entry.protein,
            carbs: entry.carbs,
            fat: entry.fat,
            fiber: entry.fiber,
            servingDescription: entry.servingDescription,
            servingGrams: entry.servingGrams,
            barcode: entry.barcode
        )
    }

    public func toFoodEntry(meal: MealCategory, quantity: Double = 1) -> FoodEntry {
        FoodEntry(
            name: name,
            emoji: emoji,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            servingDescription: servingDescription,
            servingGrams: servingGrams,
            quantity: quantity,
            barcode: barcode,
            source: .template,
            mealCategory: meal
        )
    }

    public func recordUsage() {
        usageCount += 1
        lastUsed = Date()
    }
}
