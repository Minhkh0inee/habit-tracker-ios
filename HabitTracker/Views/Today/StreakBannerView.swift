import SwiftUI

private enum Layout {
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 14
    static let headerSpacing: CGFloat = 10
    static let flameBackgroundSize: CGFloat = 46
    static let flameSymbolSize: CGFloat = 22
    static let dividerHeight: CGFloat = 1
    static let pillSpacing: CGFloat = 10
    static let pillHorizontalPadding: CGFloat = 10
    static let pillVerticalPadding: CGFloat = 6
    static let pillIconSize: CGFloat = 11
    static let badgeCornerRadius: CGFloat = 8
}

private enum TextLabel {
    static let headerTitle = "DAILY STREAK"
    static let daySingular = "day"
    static let dayPlural = "days"
    static let atRiskWarning = "⚠️ AT RISK"
    static let allDoneBadge = "★ All Done!"
    static let activeTodayBadge = "✓ Active today"
    static let trophyIcon = "trophy.fill"
    
    static func bestStreak(_ count: Int) -> String {
        "Best \(count)d"
    }
}

public struct StreakBannerView: View {
    public let habits: [Habit]

    public init(habits: [Habit]) {
        self.habits = habits
    }

    private var globalInfo: StreakInfo {
        let dict = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, $0.completedSessionDates) })
        return StreakEngine.globalStreakInfo(habitCompletedDates: dict)
    }

    private var allHabitsCompletedToday: Bool {
        guard !habits.isEmpty else { return false }
        return habits.allSatisfy { $0.isCompletedToday }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            globalStreakHeader

            if habits.count > 1 {
                habitFlameRow
            }
        }
        .padding(Layout.cardPadding)
        .bentoCard()
    }

    private var globalStreakHeader: some View {
        HStack(spacing: Layout.headerSpacing) {
            ZStack {
                Circle()
                    .fill(globalInfo.status.backgroundColor.opacity(0.15))
                    .frame(width: Layout.flameBackgroundSize, height: Layout.flameBackgroundSize)
                Image(systemName: globalInfo.status.flameSymbol)
                    .font(.system(size: Layout.flameSymbolSize, weight: .semibold))
                    .foregroundStyle(globalInfo.status.flameGradient)
                    .symbolEffect(.pulse, options: .repeating, isActive: globalInfo.currentStreak > 0)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(TextLabel.headerTitle)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(globalInfo.currentStreak)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .contentTransition(.numericText())
                    Text(globalInfo.currentStreak == 1 ? TextLabel.daySingular : TextLabel.dayPlural)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if globalInfo.longestStreak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: TextLabel.trophyIcon)
                            .font(.system(size: 10))
                        Text(TextLabel.bestStreak(globalInfo.longestStreak))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }

                if globalInfo.isAtRisk {
                    Text(TextLabel.atRiskWarning)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                }

                if allHabitsCompletedToday {
                    Text(TextLabel.allDoneBadge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                } else if globalInfo.isActiveToday {
                    Text(TextLabel.activeTodayBadge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
            }
        }
    }

    private var habitFlameRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: Layout.dividerHeight)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Layout.pillSpacing) {
                    ForEach(habits) { habit in
                        HabitFlamePill(habit: habit)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
    }
}

private struct HabitFlamePill: View {
    let habit: Habit

    private var info: StreakInfo {
        habit.streakInfo
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: habit.iconName)
                .font(.system(size: Layout.pillIconSize, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            Image(systemName: info.status.flameSymbol)
                .font(.system(size: Layout.pillIconSize, weight: .semibold))
                .foregroundStyle(info.status.flameGradient)

            Text("\(info.currentStreak)d")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(info.currentStreak > 0 ? AppTheme.textPrimary : AppTheme.textTertiary)
        }
        .padding(.horizontal, Layout.pillHorizontalPadding)
        .padding(.vertical, Layout.pillVerticalPadding)
        .background(info.status.backgroundColor.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(info.status.backgroundColor.opacity(info.currentStreak > 0 ? 0.25 : 0.1), lineWidth: 1)
        )
    }
}

public extension StreakStatus {
    var backgroundColor: Color {
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

    var flameGradient: LinearGradient {
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
