import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct StreakTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), data: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        if context.isPreview {
            completion(StreakEntry(date: Date(), data: .preview))
            return
        }
        let data = StreakWidgetSnapshotService.shared.readSnapshot()
        let resolved = (data.currentStreak == 0 && data.totalHabitsCount == 0) ? .preview : data
        completion(StreakEntry(date: Date(), data: resolved))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let currentDate = Date()
        let data = StreakWidgetSnapshotService.shared.readSnapshot()
        let entry = StreakEntry(date: currentDate, data: data)

        // Schedule next reload at start of tomorrow or 1 hour from now
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: currentDate)) ?? currentDate.addingTimeInterval(3600)
        let nextHour = currentDate.addingTimeInterval(3600)
        let reloadDate = min(tomorrow, nextHour)

        let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct StreakEntry: TimelineEntry {
    let date: Date
    let data: StreakWidgetData
}

// MARK: - Main Widget View
struct StreakWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: StreakTimelineProvider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallStreakView(data: entry.data)
            case .systemMedium:
                MediumStreakView(data: entry.data)
            case .accessoryCircular:
                AccessoryCircularView(data: entry.data)
            case .accessoryRectangular:
                AccessoryRectangularView(data: entry.data)
            case .accessoryInline:
                AccessoryInlineView(data: entry.data)
            @unknown default:
                SmallStreakView(data: entry.data)
            }
        }
        .widgetURL(URL(string: "habittracker://streak"))
    }
}

// MARK: - Small Widget View
private struct SmallStreakView: View {
    let data: StreakWidgetData

    private var streakIconName: String {
        data.isAtRisk ? "snowflake" : data.status.flameSymbol
    }

    private var iconGradient: LinearGradient {
        if data.isAtRisk {
            return LinearGradient(
                colors: [Color(red: 0.25, green: 0.70, blue: 1.0), Color(red: 0.65, green: 0.90, blue: 1.0)],
                startPoint: .bottom,
                endPoint: .top
            )
        } else {
            return data.status.flameGradient
        }
    }

    private var iconBackgroundFill: Color {
        if data.isAtRisk {
            return Color.cyan.opacity(0.22)
        } else {
            return data.status.backgroundColor.opacity(0.18)
        }
    }

    private var subtitleGradient: LinearGradient {
        if data.isAtRisk {
            return LinearGradient(
                colors: [Color(red: 0.35, green: 0.75, blue: 1.0), Color(red: 0.55, green: 0.85, blue: 1.0)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return data.status.flameGradient
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header (clean icon, no text or trophy)
            HStack {
                ZStack {
                    Circle()
                        .fill(iconBackgroundFill)
                        .frame(width: 32, height: 32)
                    Image(systemName: streakIconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(iconGradient)
                }
                Spacer()
            }

            Spacer(minLength: 0)

            // Hero streak counter (larger 1 day)
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(data.currentStreak)")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text(data.currentStreak == 1 ? "day" : "days")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Text(data.status.title.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(subtitleGradient)
            }

            Spacer(minLength: 0)

            // Status Badge (hidden when at risk; communicates state via grey background + ice icon)
            statusBadge
        }
        .padding(14)
        .containerBackground(for: .widget) {
            if data.isAtRisk {
                Color(uiColor: .systemGray4)
            } else {
                Color(uiColor: .secondarySystemBackground)
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if data.isAtRisk {
            EmptyView()
        } else if data.allHabitsCompletedToday {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                Text("All Done!")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundColor(.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.14))
            .clipShape(Capsule())
        } else if data.isActiveToday {
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
                Text("Active today")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundColor(.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.14))
            .clipShape(Capsule())
        } else if data.totalHabitsCount > 0 {
            HStack(spacing: 4) {
                Text("\(data.todayCompletedCount)/\(data.totalHabitsCount) done")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.06))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Medium Widget View
private struct MediumStreakView: View {
    let data: StreakWidgetData

    var body: some View {
        HStack(spacing: 16) {
            // Left Hero Column
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(data.status.backgroundColor.opacity(0.18))
                            .frame(width: 32, height: 32)
                        Image(systemName: data.status.flameSymbol)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(data.status.flameGradient)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("DAILY STREAK")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                        Text(data.status.title)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(data.status.flameGradient)
                    }
                }

                Spacer(minLength: 0)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(data.currentStreak)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)

                    Text(data.currentStreak == 1 ? "day" : "days")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 0)

                if data.longestStreak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 10))
                        Text("Best \(data.longestStreak)d")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                }

                leftStatusPill
            }
            .frame(width: 120, alignment: .leading)

            // Divider
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(width: 1)

            // Right Breakdown Column
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("HABITS TODAY")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(data.todayCompletedCount)/\(data.totalHabitsCount)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }

                if data.habits.isEmpty {
                    Spacer()
                    Text("No habits configured yet.\nOpen the app to start tracking!")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                } else {
                    VStack(spacing: 6) {
                        ForEach(data.habits.prefix(3)) { habit in
                            HabitRowView(habit: habit)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color(uiColor: .secondarySystemBackground)
        }
    }

    @ViewBuilder
    private var leftStatusPill: some View {
        if data.isAtRisk {
            Text("⚠️ AT RISK")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.15))
                .clipShape(Capsule())
        } else if data.isActiveToday {
            Text("✓ Active today")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.green)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.15))
                .clipShape(Capsule())
        } else {
            Text("In progress")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.primary.opacity(0.06))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Habit Row View for Medium Widget
private struct HabitRowView: View {
    let habit: HabitStreakSummary

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: habit.iconName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 16)

            Text(habit.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()

            // Habit Streak Pill
            HStack(spacing: 3) {
                Image(systemName: habit.status.flameSymbol)
                    .font(.system(size: 9))
                    .foregroundStyle(habit.status.flameGradient)
                Text("\(habit.streak)d")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(habit.streak > 0 ? .primary : .secondary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(habit.status.backgroundColor.opacity(0.1))
            .clipShape(Capsule())

            // Completed indicator
            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(habit.isCompletedToday ? .green : Color.primary.opacity(0.2))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Lock Screen Accessories
private struct AccessoryCircularView: View {
    let data: StreakWidgetData

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: data.status.flameSymbol)
                    .font(.system(size: 12, weight: .bold))
                Text("\(data.currentStreak)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
            }
        }
    }
}

private struct AccessoryRectangularView: View {
    let data: StreakWidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: data.status.flameSymbol)
                    .font(.system(size: 12, weight: .bold))
                Text("\(data.currentStreak) Day Streak")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }

            Text("\(data.todayCompletedCount)/\(data.totalHabitsCount) completed today")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)

            if data.isAtRisk {
                Text("⚠️ Streak at risk")
                    .font(.system(size: 10, weight: .bold))
            } else if data.isActiveToday {
                Text("✓ Streak kept alive")
                    .font(.system(size: 10, weight: .medium))
            } else {
                Text("Best: \(data.longestStreak) days")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct AccessoryInlineView: View {
    let data: StreakWidgetData

    var body: some View {
        Label {
            Text("\(data.currentStreak)d streak • \(data.isActiveToday ? "Done" : (data.isAtRisk ? "At risk" : "\(data.todayCompletedCount)/\(data.totalHabitsCount)"))")
        } icon: {
            Image(systemName: data.status.flameSymbol)
        }
    }
}

// MARK: - Widget Declaration
struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Momentum Streak")
        .description("Keep your streak alive and track daily habits directly from your Home & Lock Screen.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
