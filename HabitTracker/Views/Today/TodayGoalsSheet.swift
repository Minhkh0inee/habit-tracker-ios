import SwiftUI
import SwiftData

public struct TodayGoalsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable public var habit: Habit
    public let onStartTimerWithConcept: ((Habit, CurriculumConcept) -> Void)?
    
    @State private var expandedConceptIDs: Set<UUID> = []
    
    public init(
        habit: Habit,
        onStartTimerWithConcept: ((Habit, CurriculumConcept) -> Void)? = nil
    ) {
        self.habit = habit
        self.onStartTimerWithConcept = onStartTimerWithConcept
    }
    
    private var todayConcepts: [CurriculumConcept] {
        habit.todayAllGoals
    }
    
    private var todayTotalCount: Int {
        todayConcepts.count
    }
    
    private var todayCompletedCount: Int {
        todayConcepts.filter(\.isCompleted).count
    }
    
    private var todayProgressRatio: Double {
        guard todayTotalCount > 0 else { return 1.0 }
        return Double(todayCompletedCount) / Double(todayTotalCount)
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Overview Card for Today's Goals
                        todayGoalProgressCard
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Today's Scheduled Concepts (Only showing Today's Goals)
                        todayScheduledSection
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
                .scrollBounceBehavior(.basedOnSize)
                .background(AppTheme.background.ignoresSafeArea())
                .navigationTitle("\(habit.title) Goals")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Progress Overview Card (Driven strictly by Today's Goals)
    private var todayGoalProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TODAY'S GOAL PROGRESS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("\(todayCompletedCount) of \(todayTotalCount) Tasks Done")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                Text("\(Int(todayProgressRatio * 100))%")
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundColor(todayCompletedCount == todayTotalCount && todayTotalCount > 0 ? Color.green : AppTheme.textPrimary)
            }
            
            // Progress Bar
            MinimalProgressBar(progress: todayProgressRatio, height: 8)
            
            if todayCompletedCount == todayTotalCount && todayTotalCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color.green)
                    Text("All goals for today completed! 🎉")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundColor(Color.green)
                }
            }
        }
        .padding(16)
        .bentoCard()
    }
    
    // MARK: - Today's Scheduled Concepts Section
    private var todayScheduledSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🎯 Today's Goals (~\(habit.todayScheduledMinutes)m)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(todayTotalCount) Planned")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if todayConcepts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color.green)
                        .padding(.bottom, 2)
                    
                    Text("All Caught Up for Today! 🎉")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("You have completed all scheduled tasks for today.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .bentoCard()
            } else {
                ForEach(todayConcepts) { concept in
                    conceptCardView(concept: concept)
                }
            }
        }
    }
    
    // MARK: - Expandable Concept Card View
    private func conceptCardView(concept: CurriculumConcept) -> some View {
        let isExpanded = expandedConceptIDs.contains(concept.id)
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Checkmark toggle button
                Button(action: { toggleComplete(concept) }) {
                    Image(systemName: concept.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(concept.isCompleted ? Color.green : AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if concept.isRolledOver {
                            Text("ROLLED OVER")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.18))
                                .foregroundColor(.orange)
                                .clipShape(Capsule())
                        }
                        
                        Text("\(concept.estimatedMinutes)m")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.surface)
                            .foregroundColor(AppTheme.textSecondary)
                            .clipShape(Capsule())
                        
                        if concept.isAISynced {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Text(concept.title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .strikethrough(concept.isCompleted)
                    
                    if !concept.conceptDescription.isEmpty {
                        Text(concept.conceptDescription)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(isExpanded ? nil : 2)
                    }
                    
                    if isExpanded, let completedDate = concept.completedDate {
                        Text("Completed on \(AppFormatters.mediumDate(completedDate))")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(Color.green)
                            .padding(.top, 2)
                    }
                }
            }
            
            // Timer launch button when expanded
            if isExpanded && !concept.isCompleted && onStartTimerWithConcept != nil {
                Button(action: {
                    onStartTimerWithConcept?(habit, concept)
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11))
                        Text("Start Focus Session (~\(concept.estimatedMinutes)m)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(AppTheme.textPrimary)
                    .foregroundColor(AppTheme.buttonForeground)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .bentoCard()
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if expandedConceptIDs.contains(concept.id) {
                    expandedConceptIDs.remove(concept.id)
                } else {
                    expandedConceptIDs.insert(concept.id)
                }
            }
        }
    }
    
    // MARK: - Toggle Complete
    private func toggleComplete(_ concept: CurriculumConcept) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            concept.isCompleted.toggle()
            if concept.isCompleted {
                concept.completedDate = Date()
                
                let targetTitle = concept.title
                let existingDescriptor = FetchDescriptor<LessonItem>(
                    predicate: #Predicate<LessonItem> { item in
                        item.title == targetTitle
                    }
                )
                let existing = (try? modelContext.fetch(existingDescriptor)) ?? []
                if existing.isEmpty {
                    let lessonItem = LessonItem(
                        title: concept.title,
                        notes: concept.conceptDescription,
                        category: habit.category,
                        habit: habit
                    )
                    modelContext.insert(lessonItem)
                }
            } else {
                concept.completedDate = nil
            }
            try? modelContext.save()
        }
    }
}
