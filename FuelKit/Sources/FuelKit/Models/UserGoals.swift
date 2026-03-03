import Foundation
import SwiftData

@Model
public final class UserGoals {
    public var id: UUID
    public var dailyCalories: Int
    public var proteinGrams: Double
    public var carbsGrams: Double
    public var fatGrams: Double
    public var waterGlasses: Int
    public var targetWeight: Double?
    public var weightUnitRaw: String
    public var createdAt: Date
    public var updatedAt: Date

    public var weightUnit: WeightUnit {
        get { WeightUnit(rawValue: weightUnitRaw) ?? .lbs }
        set { weightUnitRaw = newValue.rawValue }
    }

    public init(
        dailyCalories: Int = 2000,
        proteinGrams: Double = 150,
        carbsGrams: Double = 200,
        fatGrams: Double = 65,
        waterGlasses: Int = 8,
        targetWeight: Double? = nil,
        weightUnit: WeightUnit = .lbs
    ) {
        self.id = UUID()
        self.dailyCalories = dailyCalories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.waterGlasses = waterGlasses
        self.targetWeight = targetWeight
        self.weightUnitRaw = weightUnit.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    public static var defaults: UserGoals {
        UserGoals()
    }
}
