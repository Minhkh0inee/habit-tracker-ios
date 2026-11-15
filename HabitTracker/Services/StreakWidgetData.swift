import Foundation
import SwiftUI

public struct HabitStreakSummary: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let iconName: String
    public let streak: Int
    public let isCompletedToday: Bool
    public let statusRaw: String

    public var status: StreakStatus {
        StreakStatus(rawValue: statusRaw) ?? .none
    }

    public init(
        id: String,
        title: String,
        iconName: String,
        streak: Int,
        isCompletedToday: Bool,
        statusRaw: String
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.streak = streak
        self.isCompletedToday = isCompletedToday
        self.statusRaw = statusRaw
    }
}

public struct StreakWidgetData: Codable, Equatable {
    public let currentStreak: Int
    public let longestStreak: Int
    public let isActiveToday: Bool
    public let isAtRisk: Bool
    public let canUseGrace: Bool
    public let statusRaw: String
    public let todayCompletedCount: Int
    public let totalHabitsCount: Int
    public let habits: [HabitStreakSummary]
    public let lastUpdated: Date

    public var status: StreakStatus {
        StreakStatus(rawValue: statusRaw) ?? .none
    }

    public var allHabitsCompletedToday: Bool {
        totalHabitsCount > 0 && todayCompletedCount >= totalHabitsCount
    }

    public init(
        currentStreak: Int,
        longestStreak: Int,
        isActiveToday: Bool,
        isAtRisk: Bool,
        canUseGrace: Bool,
        statusRaw: String,
        todayCompletedCount: Int,
        totalHabitsCount: Int,
        habits: [HabitStreakSummary],
        lastUpdated: Date
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.isActiveToday = isActiveToday
        self.isAtRisk = isAtRisk
        self.canUseGrace = canUseGrace
        self.statusRaw = statusRaw
        self.todayCompletedCount = todayCompletedCount
        self.totalHabitsCount = totalHabitsCount
        self.habits = habits
        self.lastUpdated = lastUpdated
    }

    public static let empty = StreakWidgetData(
        currentStreak: 0,
        longestStreak: 0,
        isActiveToday: false,
        isAtRisk: false,
        canUseGrace: false,
        statusRaw: StreakStatus.none.rawValue,
        todayCompletedCount: 0,
        totalHabitsCount: 0,
        habits: [],
        lastUpdated: Date()
    )

    public static let preview = StreakWidgetData(
        currentStreak: 7,
        longestStreak: 14,
        isActiveToday: true,
        isAtRisk: false,
        canUseGrace: false,
        statusRaw: StreakStatus.hot.rawValue,
        todayCompletedCount: 2,
        totalHabitsCount: 3,
        habits: [
            HabitStreakSummary(id: "1", title: "LeetCode Daily", iconName: "brain.head.profile", streak: 7, isCompletedToday: true, statusRaw: StreakStatus.hot.rawValue),
            HabitStreakSummary(id: "2", title: "System Design", iconName: "network", streak: 5, isCompletedToday: true, statusRaw: StreakStatus.building.rawValue),
            HabitStreakSummary(id: "3", title: "Core CS Reading", iconName: "book.fill", streak: 3, isCompletedToday: false, statusRaw: StreakStatus.building.rawValue)
        ],
        lastUpdated: Date()
    )

    public static let atRiskPreview = StreakWidgetData(
        currentStreak: 5,
        longestStreak: 10,
        isActiveToday: false,
        isAtRisk: true,
        canUseGrace: false,
        statusRaw: StreakStatus.building.rawValue,
        todayCompletedCount: 0,
        totalHabitsCount: 3,
        habits: [
            HabitStreakSummary(id: "1", title: "LeetCode Daily", iconName: "brain.head.profile", streak: 5, isCompletedToday: false, statusRaw: StreakStatus.building.rawValue),
            HabitStreakSummary(id: "2", title: "System Design", iconName: "network", streak: 4, isCompletedToday: false, statusRaw: StreakStatus.building.rawValue),
            HabitStreakSummary(id: "3", title: "Core CS Reading", iconName: "book.fill", streak: 2, isCompletedToday: false, statusRaw: StreakStatus.building.rawValue)
        ],
        lastUpdated: Date()
    )
}
