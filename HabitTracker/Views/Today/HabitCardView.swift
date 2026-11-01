import SwiftUI

public struct HabitCardView: View {
    public let habit: Habit
    public let onStartTimer: (Habit) -> Void
    public let onDirectLog: (Habit) -> Void
    
    public init(
        habit: Habit,
        onStartTimer: @escaping (Habit) -> Void,
        onDirectLog: @escaping (Habit) -> Void
    ) {
        self.habit = habit
        self.onStartTimer = onStartTimer
        self.onDirectLog = onDirectLog
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Habit Icon
            Image(systemName: habit.iconName)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 44, height: 44)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            
            // Habit Details
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.category.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(habit.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if habit.isCompletedToday {
                        Text("\(habit.totalMinutesToday)m logged")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    } else {
                        Text("Target: \(habit.targetMinutes)m")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Right Side Action / Status
            if habit.isCompletedToday {
                // Completed status badge & thumbnail
                HStack(spacing: 8) {
                    if let latestSession = habit.completedSessionsToday.last,
                       let photoName = latestSession.photoFileName,
                       let proofImage = ImageStorageService.shared.loadProofImage(named: photoName) {
                        Image(uiImage: proofImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                    }
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.textPrimary)
                }
            } else {
                // Action Buttons: Quick Snap Proof or Start Timer
                HStack(spacing: 6) {
                    Button(action: { onDirectLog(habit) }) {
                        Image(systemName: "camera")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 34, height: 34)
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(AppTheme.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { onStartTimer(habit) }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.buttonForeground)
                            .frame(width: 34, height: 34)
                            .background(AppTheme.buttonBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .bentoCard()
    }
}
