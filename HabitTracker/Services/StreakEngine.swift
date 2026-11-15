import Foundation
import SwiftUI

private enum StreakThreshold {
    static let buildingRange = 1...6
    static let hotRange = 7...13
    static let blazingRange = 14...29
    static let legendaryMin = 30
}

private enum StreakSymbol {
    static let emptyFlame = "flame"
    static let filledFlame = "flame.fill"
}

public enum StreakStatus: String, Codable, CaseIterable, Equatable {
    case none = "none"
    case building = "building"
    case hot = "hot"
    case blazing = "blazing"
    case legendary = "legendary"

    public static func from(streak: Int) -> StreakStatus {
        switch streak {
        case 0:
            return .none
        case StreakThreshold.buildingRange:
            return .building
        case StreakThreshold.hotRange:
            return .hot
        case StreakThreshold.blazingRange:
            return .blazing
        default:
            return .legendary
        }
    }

    public var title: String {
        switch self {
        case .none:
            return "No Streak"
        case .building:
            return "Building"
        case .hot:
            return "Hot"
        case .blazing:
            return "Blazing"
        case .legendary:
            return "Legendary"
        }
    }

    public var flameSymbol: String {
        switch self {
        case .none:
            return StreakSymbol.emptyFlame
        default:
            return StreakSymbol.filledFlame
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .none:
            return Color.gray
        case .building:
            return Color.yellow
        case .hot:
            return Color.orange
        case .blazing:
            return Color.red
        case .legendary:
            return Color.purple
        }
    }

    public var flameGradient: LinearGradient {
        switch self {
        case .none:
            return LinearGradient(
                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                startPoint: .bottom,
                endPoint: .top
            )
        case .building:
            return LinearGradient(
                colors: [Color.yellow, Color.orange.opacity(0.7)],
                startPoint: .bottom,
                endPoint: .top
            )
        case .hot:
            return LinearGradient(
                colors: [Color.orange, Color.red.opacity(0.7)],
                startPoint: .bottom,
                endPoint: .top
            )
        case .blazing:
            return LinearGradient(
                colors: [Color.red, Color.orange.opacity(0.6)],
                startPoint: .bottom,
                endPoint: .top
            )
        case .legendary:
            return LinearGradient(
                colors: [Color.purple, Color.pink.opacity(0.7)],
                startPoint: .bottom,
                endPoint: .top
            )
        }
    }
}

public struct StreakInfo: Equatable {
    public let currentStreak: Int
    public let longestStreak: Int
    public let lastActiveDate: Date?
    public let isActiveToday: Bool
    public let isAtRisk: Bool
    public let canUseGrace: Bool

    public var status: StreakStatus {
        .from(streak: currentStreak)
    }

    public static let zero = StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: nil,
        isActiveToday: false,
        isAtRisk: false,
        canUseGrace: false
    )

    public init(
        currentStreak: Int,
        longestStreak: Int,
        lastActiveDate: Date?,
        isActiveToday: Bool,
        isAtRisk: Bool,
        canUseGrace: Bool
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDate = lastActiveDate
        self.isActiveToday = isActiveToday
        self.isAtRisk = isAtRisk
        self.canUseGrace = canUseGrace
    }
}

public enum StreakEngine {
    public static func streakInfo(
        from completedDates: [Date],
        graceDatesUsed: Set<Date> = [],
        calendar: Calendar = .current
    ) -> StreakInfo {
        let uniqueDays = uniqueStartOfDays(from: completedDates, calendar: calendar)
        guard !uniqueDays.isEmpty else { return .zero }

        let today = calendar.startOfDay(for: Date())
        let isActiveToday = uniqueDays.contains(today)
        let lastActiveDate = uniqueDays.first

        let (currentStreak, canUseGrace) = computeCurrentStreak(
            days: uniqueDays,
            today: today,
            graceDatesUsed: graceDatesUsed,
            calendar: calendar
        )

        let longestStreak = computeLongestStreak(days: uniqueDays, calendar: calendar)

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let isAtRisk = !isActiveToday && uniqueDays.contains(yesterday)

        return StreakInfo(
            currentStreak: currentStreak,
            longestStreak: max(longestStreak, currentStreak),
            lastActiveDate: lastActiveDate,
            isActiveToday: isActiveToday,
            isAtRisk: isAtRisk,
            canUseGrace: canUseGrace
        )
    }

    public static func globalStreakInfo(
        habitCompletedDates: [UUID: [Date]],
        graceDatesUsed: Set<Date> = [],
        calendar: Calendar = .current
    ) -> StreakInfo {
        let allDates = habitCompletedDates.values.flatMap { $0 }
        guard !allDates.isEmpty else { return .zero }

        return streakInfo(
            from: allDates,
            graceDatesUsed: graceDatesUsed,
            calendar: calendar
        )
    }

    private static func uniqueStartOfDays(from dates: [Date], calendar: Calendar) -> [Date] {
        let starts = dates.map { calendar.startOfDay(for: $0) }
        return Array(Set(starts)).sorted(by: >)
    }

    private static func computeCurrentStreak(
        days: [Date],
        today: Date,
        graceDatesUsed: Set<Date>,
        calendar: Calendar
    ) -> (Int, Bool) {
        let daySet = Set(days)

        var streak = 0
        let graceAvailable = true
        var graceConsumed = false
        var canUseGrace = false

        var cursor: Date
        if daySet.contains(today) {
            cursor = today
        } else {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today), daySet.contains(yesterday) else {
                return (0, false)
            }
            cursor = yesterday
        }

        while true {
            if daySet.contains(cursor) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = previousDay
            } else if graceAvailable && !graceConsumed {
                guard let dayBeforeGap = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                if daySet.contains(dayBeforeGap) {
                    let gapDay = cursor
                    if graceDatesUsed.contains(gapDay) {
                        graceConsumed = true
                        cursor = dayBeforeGap
                    } else {
                        canUseGrace = true
                        break
                    }
                } else {
                    break
                }
            } else {
                break
            }
        }

        return (streak, canUseGrace)
    }

    private static func computeLongestStreak(days: [Date], calendar: Calendar) -> Int {
        guard !days.isEmpty else { return 0 }

        let sortedAsc = days.sorted(by: <)
        var longest = 1
        var current = 1

        for i in 1..<sortedAsc.count {
            let diff = calendar.dateComponents([.day], from: sortedAsc[i - 1], to: sortedAsc[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return longest
    }
}
