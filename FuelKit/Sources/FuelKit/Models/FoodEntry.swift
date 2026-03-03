import Foundation
import SwiftData

public enum FoodSource: String, Codable, CaseIterable {
    case manual
    case ai
    case barcode
    case quickAdd
    case template
}

public enum MealCategory: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snacks: return "🍿"
        }
    }

    public var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch: return 1
        case .dinner: return 2
        case .snacks: return 3
        }
    }
}

@Model
public final class FoodEntry {
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
    public var quantity: Double
    public var barcode: String?
    public var sourceRaw: String
    public var mealCategoryRaw: String
    public var originalInput: String?
    public var confidence: Double
    public var createdAt: Date

    public var dailyLog: DailyLog?

    public var source: FoodSource {
        get { FoodSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public var mealCategory: MealCategory {
        get { MealCategory(rawValue: mealCategoryRaw) ?? .snacks }
        set { mealCategoryRaw = newValue.rawValue }
    }

    public var totalCalories: Int {
        Int(Double(calories) * quantity)
    }

    public var totalProtein: Double {
        protein * quantity
    }

    public var totalCarbs: Double {
        carbs * quantity
    }

    public var totalFat: Double {
        fat * quantity
    }

    public var totalFiber: Double {
        fiber * quantity
    }

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
        quantity: Double = 1,
        barcode: String? = nil,
        source: FoodSource = .manual,
        mealCategory: MealCategory = .snacks,
        originalInput: String? = nil,
        confidence: Double = 1.0
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
        self.quantity = quantity
        self.barcode = barcode
        self.sourceRaw = source.rawValue
        self.mealCategoryRaw = mealCategory.rawValue
        self.originalInput = originalInput
        self.confidence = confidence
        self.createdAt = Date()
    }
}
