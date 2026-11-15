import Foundation

public extension Habit {
    var completedSessionDates: [Date] {
        sessions
            .filter { $0.isCompleted }
            .map { $0.date }
    }

    var streakInfo: StreakInfo {
        StreakEngine.streakInfo(from: completedSessionDates)
    }

    var currentStreak: Int {
        streakInfo.currentStreak
    }

    var longestStreak: Int {
        streakInfo.longestStreak
    }

    var streakIsActiveToday: Bool {
        streakInfo.isActiveToday
    }
}
