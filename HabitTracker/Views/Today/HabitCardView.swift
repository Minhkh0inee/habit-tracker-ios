import SwiftUI

public struct HabitCardView: View {
    public let habit: Habit
    public let onStartTimer: (Habit) -> Void
    public let onDirectLog: (Habit) -> Void
    public let onOpenCurriculum: (Habit) -> Void
    public let onEditHabit: (Habit) -> Void
    
    public init(
        habit: Habit,
        onStartTimer: @escaping (Habit) -> Void,
        onDirectLog: @escaping (Habit) -> Void,
        onOpenCurriculum: @escaping (Habit) -> Void,
        onEditHabit: @escaping (Habit) -> Void
    ) {
        self.habit = habit
        self.onStartTimer = onStartTimer
        self.onDirectLog = onDirectLog
        self.onOpenCurriculum = onOpenCurriculum
        self.onEditHabit = onEditHabit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Top Main Row
            HStack(spacing: 12) {
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
                
                // Right Side Actions / Completed Indicator
                if habit.isCompletedToday {
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
            
            // MARK: - Daily Curriculum Preview (Adaptive Daily Concepts with Rollover)
            let todayConcepts = habit.todayScheduledConcepts
            if !todayConcepts.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "book.pages")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("TODAY'S SYLLABUS (~\(habit.todayScheduledMinutes)m)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                        
                        Button(action: { onOpenCurriculum(habit) }) {
                            HStack(spacing: 3) {
                                Text("Roadmap")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(AppTheme.textPrimary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    ForEach(todayConcepts.prefix(2)) { concept in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(concept.isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary.opacity(0.4))
                                .frame(width: 5, height: 5)
                            
                            Text(concept.title)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if concept.isRolledOver {
                                Text("ROLLED")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Color.orange.opacity(0.18))
                                    .foregroundColor(.orange)
                                    .clipShape(Capsule())
                            }
                            
                            Text("\(concept.estimatedMinutes)m")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(10)
                .background(AppTheme.surface.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            // MARK: - Bottom Actions Bar (Roadmap & Edit)
            HStack {
                Button(action: { onOpenCurriculum(habit) }) {
                    HStack(spacing: 5) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 11))
                        Text("Syllabus (\(habit.completedCurriculum.count)/\(habit.curriculumQueue.count))")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: { onEditHabit(habit) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 11))
                        Text("Edit Habit")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .bentoCard()
    }
}
