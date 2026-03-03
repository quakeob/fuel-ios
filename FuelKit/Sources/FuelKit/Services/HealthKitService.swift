import Foundation
import HealthKit

public actor HealthKitService {
    public static let shared = HealthKitService()

    private let store = HKHealthStore()

    private init() {}

    public var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    public func requestAuthorization() async throws {
        guard isAvailable else { return }

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        ]

        try await store.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }

    // MARK: - Write Food Entry

    public func writeFoodEntry(
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        date: Date
    ) async throws {
        guard isAvailable else { return }

        var samples: [HKQuantitySample] = []

        if calories > 0 {
            let calType = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            let calQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: Double(calories))
            samples.append(HKQuantitySample(type: calType, quantity: calQuantity, start: date, end: date))
        }

        if protein > 0 {
            let proteinType = HKObjectType.quantityType(forIdentifier: .dietaryProtein)!
            let proteinQuantity = HKQuantity(unit: .gram(), doubleValue: protein)
            samples.append(HKQuantitySample(type: proteinType, quantity: proteinQuantity, start: date, end: date))
        }

        if carbs > 0 {
            let carbType = HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!
            let carbQuantity = HKQuantity(unit: .gram(), doubleValue: carbs)
            samples.append(HKQuantitySample(type: carbType, quantity: carbQuantity, start: date, end: date))
        }

        if fat > 0 {
            let fatType = HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!
            let fatQuantity = HKQuantity(unit: .gram(), doubleValue: fat)
            samples.append(HKQuantitySample(type: fatType, quantity: fatQuantity, start: date, end: date))
        }

        guard !samples.isEmpty else { return }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(samples) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Write Weight

    public func writeWeight(_ weight: Double, unit: WeightUnit, date: Date) async throws {
        guard isAvailable else { return }

        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let hkUnit: HKUnit = unit == .lbs ? .pound() : .gramUnit(with: .kilo)
        let quantity = HKQuantity(unit: hkUnit, doubleValue: weight)
        let sample = HKQuantitySample(type: weightType, quantity: quantity, start: date, end: date)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(sample) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Read Weight

    public func readLatestWeight() async throws -> (weight: Double, unit: WeightUnit, date: Date)? {
        guard isAvailable else { return nil }

        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: weightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, _, _ in }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = results?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let lbs = sample.quantity.doubleValue(for: .pound())
                continuation.resume(returning: (weight: lbs, unit: .lbs, date: sample.endDate))
            }
            self.store.execute(query)
        }
    }
}
