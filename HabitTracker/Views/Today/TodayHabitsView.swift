import SwiftUI
import SwiftData

private enum ViewConstants {
    static let testPushDelaySeconds: Double = 2.0
    static let toastDisplayDurationSeconds: Double = 3.0
}

public struct TodayHabitsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.createdAt)
    private var habits: [Habit]
    
    @Query private var allLessons: [LessonItem]
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding public var selectedTab: Int
    @Bindable public var timerViewModel: TimerViewModel
    
    @State private var showingAddHabit: Bool = false
    @State private var showingSettings: Bool = false
    @State private var showingNotificationToast: Bool = false
    @State private var showingInterviewRecall: Bool = false
    
    @State private var habitForDirectLog: Habit?
    @State private var habitForCurriculum: Habit?
    @State private var habitForEdit: Habit?
    
    public init(selectedTab: Binding<Int>, timerViewModel: TimerViewModel) {
        self._selectedTab = selectedTab
        self.timerViewModel = timerViewModel
    }
    
    private var completedCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    private var totalMinutesToday: Int {
        habits.reduce(0) { $0 + $1.totalMinutesToday }
    }
    
    private var progressRatio: Double {
        guard !habits.isEmpty else { return 0.0 }
        return Double(completedCount) / Double(habits.count)
    }
    
    private var dueReviewCount: Int {
        let now = Date()
        return allLessons.filter { $0.nextReviewDate <= now && !$0.isMastered }.count
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Header Summary
                    dailySummaryCard
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // 🔥 Streak Banner
                    if !habits.isEmpty {
                        StreakBannerView(habits: habits)
                            .padding(.horizontal)
                    }
                    
                    // Spaced Repetition Due Alert Banner (if any concepts are due)
                    if dueReviewCount > 0 {
                        Button(action: { showingInterviewRecall = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("INTERVIEW RECALL DUE")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Text("\(dueReviewCount) Concepts Ready for Revision")
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text("Recall")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.textPrimary)
                                .foregroundColor(AppTheme.buttonForeground)
                                .clipShape(Capsule())
                            }
                            .padding(14)
                            .bentoCard()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                    
                    // Habits Section Header
                    HStack {
                        Text("Today's Habits")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(completedCount)/\(habits.count) Done")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal)
                    
                    // Habit Cards
                    if habits.isEmpty {
                        emptyStateView
                            .padding(.horizontal)
                            .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(habits) { habit in
                                HabitCardView(
                                    habit: habit,
                                    onStartTimer: { targetHabit in
                                        timerViewModel.selectHabit(targetHabit)
                                        timerViewModel.start()
                                        selectedTab = 1 // Switch to Focus Timer tab
                                    },
                                    onOpenCurriculum: { targetHabit in
                                        habitForCurriculum = targetHabit
                                    }
                                )
                                .contextMenu {
                                    Button {
                                        habitForDirectLog = habit
                                    } label: {
                                        Label("Log Photo Proof", systemImage: "camera")
                                    }
                                    
                                    Button {
                                        habitForEdit = habit
                                    } label: {
                                        Label("Edit Habit", systemImage: "pencil")
                                    }
                                    
                                    Button {
                                        habitForCurriculum = habit
                                    } label: {
                                        Label("View Today's Goals", systemImage: "target")
                                    }
                                    
                                    Button(role: .destructive) {
                                        deleteHabit(habit)
                                    } label: {
                                        Label("Delete Habit", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(todayFormattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 12) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Button(action: triggerTestNotification) {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        Button(action: { showingInterviewRecall = true }) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Button(action: { showingAddHabit = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
            }
            .overlay(alignment: .top) {
                if showingNotificationToast {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(AppTheme.buttonForeground)
                        Text("Test push scheduled! Popping up in 2s...")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(AppTheme.buttonForeground)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.buttonBackground)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet()
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitSheet()
            }
            .fullScreenCover(isPresented: $showingInterviewRecall) {
                InterviewRecallView()
            }
            .sheet(item: $habitForDirectLog) { habit in
                SessionCompletionSheet(
                    habit: habit,
                    durationMinutes: habit.targetMinutes,
                    onSaved: {}
                )
            }
            .fullScreenCover(item: $habitForCurriculum) { habit in
                TodayGoalsSheet(
                    habit: habit,
                    onStartTimerWithConcept: { targetHabit, concept in
                        timerViewModel.selectHabit(targetHabit)
                        timerViewModel.setDuration(minutes: concept.estimatedMinutes)
                        timerViewModel.start()
                        selectedTab = 1
                    }
                )
            }
            .sheet(item: $habitForEdit) { habit in
                EditHabitSheet(habit: habit)
            }
            .onAppear {
                NotificationManager.shared.syncAtRiskNotification(habits: habits)
            }
            .onChange(of: completedCount) { _, _ in
                NotificationManager.shared.syncAtRiskNotification(habits: habits)
            }
        }
    }
    
    // MARK: - Summary Card
    private var dailySummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DAILY PROGRESS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("\(Int(progressRatio * 100))% Complete")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("FOCUS TIME")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("\(totalMinutesToday)m")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            
            // Minimalist Progress Bar
            MinimalProgressBar(progress: progressRatio, height: 8)
        }
        .padding(18)
        .bentoCard()
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        EmptyStateView(
            iconName: "checklist",
            title: "No Habits Yet",
            message: "Tap the '+' button above to add your first technical habit."
        )
    }
    
    // MARK: - Helpers
    private var todayFormattedDate: String {
        AppFormatters.dayAndMonth()
    }
    
    private func deleteHabit(_ habit: Habit) {
        for session in habit.sessions {
            if let photo = session.photoFileName {
                ImageStorageService.shared.deleteProofImage(named: photo)
            }
        }
        modelContext.delete(habit)
        try? modelContext.save()
    }
    
    private func triggerTestNotification() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        NotificationManager.shared.sendTestNotification(delaySeconds: ViewConstants.testPushDelaySeconds) {
            withAnimation(.spring()) {
                showingNotificationToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + ViewConstants.toastDisplayDurationSeconds) {
                withAnimation(.easeOut) {
                    showingNotificationToast = false
                }
            }
        }
    }
}
