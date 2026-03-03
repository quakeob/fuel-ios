import Foundation

// Water tracking is integrated directly into DailyLog.waterGlasses.
// This file provides convenience extensions for water-related functionality.

public extension DailyLog {
    var waterProgress: Double {
        guard targetWaterGlasses > 0 else { return 0 }
        return Double(waterGlasses) / Double(targetWaterGlasses)
    }

    // Default target - actual target comes from UserGoals
    var targetWaterGlasses: Int { 8 }

    var isWaterGoalMet: Bool {
        waterGlasses >= targetWaterGlasses
    }
}
