import Foundation
import SwiftData

public enum StreakService {
    public static func calculateStreak(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<DailyLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let logs = try? context.fetch(descriptor) else { return 0 }

        var streak = 0
        var checkDate = Date.now.startOfDay

        // If no log for today, start checking from yesterday
        if !logs.contains(where: { $0.dateKey == checkDate.dateKey && !$0.foodEntries.isEmpty }) {
            checkDate = checkDate.daysAgo(1)
        }

        for day in 0..<365 {
            let dateToCheck = checkDate.daysAgo(day)
            let key = dateToCheck.dateKey

            let hasLog = logs.contains { log in
                log.dateKey == key && !log.foodEntries.isEmpty
            }

            if hasLog {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }
}
