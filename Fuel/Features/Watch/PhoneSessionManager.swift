import Foundation
import WatchConnectivity
import SwiftData
import FuelKit

final class PhoneSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneSessionManager()

    var modelContainer: ModelContainer?
    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func setup(container: ModelContainer) {
        self.modelContainer = container
    }

    // MARK: - Send Sync to Watch

    @MainActor
    func syncToWatch() {
        guard let container = modelContainer else { return }
        let context = container.mainContext

        let todayKey = Date.now.dateKey
        var descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.dateKey == todayKey }
        )
        descriptor.fetchLimit = 1

        guard let log = try? context.fetch(descriptor).first else { return }

        let goalsDescriptor = FetchDescriptor<UserGoals>()
        let goals = try? context.fetch(goalsDescriptor).first

        let message: [String: Any] = [
            "currentCalories": log.totalCalories,
            "targetCalories": log.targetCalories,
            "protein": log.totalProtein,
            "carbs": log.totalCarbs,
            "fat": log.totalFat,
            "waterGlasses": log.waterGlasses,
            "waterTarget": goals?.waterGlasses ?? 8
        ]

        guard let session, session.isReachable else {
            try? session?.updateApplicationContext(message)
            return
        }
        session.sendMessage(message, replyHandler: nil)
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            handleWatchMessage(message)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in
            handleWatchMessage(userInfo)
        }
    }

    @MainActor
    private func handleWatchMessage(_ message: [String: Any]) {
        guard let container = modelContainer else { return }
        let context = container.mainContext

        guard let action = message["action"] as? String else { return }

        let todayKey = Date.now.dateKey
        var descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.dateKey == todayKey }
        )
        descriptor.fetchLimit = 1
        let log = try? context.fetch(descriptor).first

        switch action {
        case "addWater":
            if let log, log.waterGlasses < 20 {
                log.waterGlasses += 1
            }

        case "removeWater":
            if let log, log.waterGlasses > 0 {
                log.waterGlasses -= 1
            }

        case "quickLog":
            if let name = message["name"] as? String,
               let emoji = message["emoji"] as? String,
               let calories = message["calories"] as? Int {
                let entry = FoodEntry(
                    name: name,
                    emoji: emoji,
                    calories: calories,
                    source: .quickAdd,
                    mealCategory: .snacks
                )
                context.insert(entry)
                if let log {
                    entry.dailyLog = log
                }
            }

        case "requestSync":
            syncToWatch()
            return

        default:
            break
        }

        try? context.save()
        syncToWatch()
    }
}
