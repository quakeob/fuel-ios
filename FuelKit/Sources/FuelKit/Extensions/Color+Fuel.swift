import SwiftUI

public extension Color {
    // MARK: - Brand Colors
    static let fuelGreen = Color(red: 0.30, green: 0.80, blue: 0.40)
    static let fuelBlue = Color(red: 0.25, green: 0.55, blue: 0.95)
    static let fuelOrange = Color(red: 0.95, green: 0.55, blue: 0.20)
    static let fuelRed = Color(red: 0.90, green: 0.30, blue: 0.30)
    static let fuelPurple = Color(red: 0.60, green: 0.35, blue: 0.90)
    static let fuelYellow = Color(red: 0.95, green: 0.80, blue: 0.20)

    // MARK: - Macro Colors
    static let proteinColor = Color.fuelBlue
    static let carbsColor = Color.fuelOrange
    static let fatColor = Color.fuelPurple
    static let fiberColor = Color.fuelGreen

    // MARK: - UI Colors
    static let calorieRing = Color.fuelGreen
    static let calorieRingBackground = Color.fuelGreen.opacity(0.15)
    static let waterBlue = Color(red: 0.30, green: 0.65, blue: 0.95)
    static let streakOrange = Color.fuelOrange

    // MARK: - Surface Colors
    static let cardBackground = Color(.systemBackground)
    static let cardBackgroundSecondary = Color(.secondarySystemBackground)
    static let surfaceGrouped = Color(.systemGroupedBackground)

    // MARK: - Meal Colors
    static func mealColor(for category: MealCategory) -> Color {
        switch category {
        case .breakfast: return .fuelOrange
        case .lunch: return .fuelGreen
        case .dinner: return .fuelBlue
        case .snacks: return .fuelPurple
        }
    }
}

public extension ShapeStyle where Self == Color {
    static var fuelGreen: Color { .fuelGreen }
    static var fuelBlue: Color { .fuelBlue }
    static var fuelOrange: Color { .fuelOrange }
    static var fuelRed: Color { .fuelRed }
    static var fuelPurple: Color { .fuelPurple }
    static var fuelYellow: Color { .fuelYellow }
    static var streakOrange: Color { .streakOrange }
    static var waterBlue: Color { .waterBlue }
    static var proteinColor: Color { .proteinColor }
    static var carbsColor: Color { .carbsColor }
    static var fatColor: Color { .fatColor }
    static var calorieRing: Color { .calorieRing }
}
