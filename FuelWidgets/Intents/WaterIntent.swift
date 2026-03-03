import AppIntents
import SwiftData
import WidgetKit
import FuelKit

struct LogWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Water"
    static var description: IntentDescription = "Add a glass of water to today's log"

    func perform() async throws -> some IntentResult {
        let container = try FuelModelContainer.create()
        let context = ModelContext(container)

        let todayKey = Date.now.dateKey
        var descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.dateKey == todayKey }
        )
        descriptor.fetchLimit = 1

        if let log = try context.fetch(descriptor).first {
            log.waterGlasses += 1
            try context.save()
        }

        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
