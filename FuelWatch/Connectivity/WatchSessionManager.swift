import Foundation
import WatchConnectivity
import FuelKit

@Observable
final class WatchSessionManager: NSObject, WCSessionDelegate {
    var currentCalories: Int = 0
    var targetCalories: Int = 2000
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var waterGlasses: Int = 0
    var waterTarget: Int = 8

    var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return Double(currentCalories) / Double(targetCalories)
    }

    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // MARK: - Actions

    func addWater() {
        waterGlasses += 1
        sendMessage(["action": "addWater"])
    }

    func removeWater() {
        guard waterGlasses > 0 else { return }
        waterGlasses -= 1
        sendMessage(["action": "removeWater"])
    }

    func quickLog(name: String, emoji: String, calories: Int) {
        currentCalories += calories
        sendMessage([
            "action": "quickLog",
            "name": name,
            "emoji": emoji,
            "calories": calories
        ])
    }

    func requestSync() {
        sendMessage(["action": "requestSync"])
    }

    // MARK: - WCSession

    private func sendMessage(_ message: [String: Any]) {
        guard let session, session.isReachable else {
            // Use transferUserInfo for background delivery
            session?.transferUserInfo(message)
            return
        }
        session.sendMessage(message, replyHandler: nil)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            requestSync()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.handleMessage(message)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        DispatchQueue.main.async {
            self.handleMessage(userInfo)
        }
    }

    private func handleMessage(_ message: [String: Any]) {
        if let calories = message["currentCalories"] as? Int {
            currentCalories = calories
        }
        if let target = message["targetCalories"] as? Int {
            targetCalories = target
        }
        if let p = message["protein"] as? Double { protein = p }
        if let c = message["carbs"] as? Double { carbs = c }
        if let f = message["fat"] as? Double { fat = f }
        if let w = message["waterGlasses"] as? Int { waterGlasses = w }
        if let wt = message["waterTarget"] as? Int { waterTarget = wt }
    }
}
