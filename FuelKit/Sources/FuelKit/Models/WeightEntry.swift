import Foundation
import SwiftData

public enum WeightUnit: String, Codable, CaseIterable {
    case lbs
    case kg

    public var label: String {
        switch self {
        case .lbs: return "lbs"
        case .kg: return "kg"
        }
    }

    public func convert(_ value: Double, to target: WeightUnit) -> Double {
        if self == target { return value }
        switch (self, target) {
        case (.lbs, .kg): return value * 0.453592
        case (.kg, .lbs): return value / 0.453592
        default: return value
        }
    }
}

public enum WeightSource: String, Codable {
    case manual
    case healthKit
}

@Model
public final class WeightEntry {
    public var id: UUID
    public var weight: Double
    public var unitRaw: String
    public var date: Date
    public var dateKey: String
    public var sourceRaw: String
    public var note: String?

    public var unit: WeightUnit {
        get { WeightUnit(rawValue: unitRaw) ?? .lbs }
        set { unitRaw = newValue.rawValue }
    }

    public var weightSource: WeightSource {
        get { WeightSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public func weight(in targetUnit: WeightUnit) -> Double {
        unit.convert(weight, to: targetUnit)
    }

    public init(
        weight: Double = 0,
        unit: WeightUnit = .lbs,
        date: Date = .now,
        source: WeightSource = .manual,
        note: String? = nil
    ) {
        self.id = UUID()
        self.weight = weight
        self.unitRaw = unit.rawValue
        self.date = date
        self.dateKey = date.dateKey
        self.sourceRaw = source.rawValue
        self.note = note
    }
}
