import Foundation
import SwiftData

public extension StreakWidgetSnapshotService {
    func saveSnapshot(from habits: [Habit]) {
        let dict = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, $0.completedSessionDates) })
        let globalInfo = StreakEngine.globalStreakInfo(habitCompletedDates: dict)
        
        let habitSummaries = habits.map { habit -> HabitStreakSummary in
            let info = habit.streakInfo
            return HabitStreakSummary(
                id: habit.id.uuidString,
                title: habit.title,
                iconName: habit.iconName,
                streak: info.currentStreak,
                isCompletedToday: habit.isCompletedToday,
                statusRaw: info.status.rawValue
            )
        }
        
        let completedTodayCount = habits.filter { $0.isCompletedToday }.count
        
        let data = StreakWidgetData(
            currentStreak: globalInfo.currentStreak,
            longestStreak: globalInfo.longestStreak,
            isActiveToday: globalInfo.isActiveToday,
            isAtRisk: globalInfo.isAtRisk,
            canUseGrace: globalInfo.canUseGrace,
            statusRaw: globalInfo.status.rawValue,
            todayCompletedCount: completedTodayCount,
            totalHabitsCount: habits.count,
            habits: habitSummaries,
            lastUpdated: Date()
        )
        
        save(data)
    }
}
