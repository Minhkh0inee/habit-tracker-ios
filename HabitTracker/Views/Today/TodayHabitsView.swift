import SwiftUI
import SwiftData

public struct TodayHabitsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.createdAt)
    private var habits: [Habit]
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding public var selectedTab: Int
    @Bindable public var timerViewModel: TimerViewModel
    
    @State private var showingAddHabit: Bool = false
    @State private var showingSettings: Bool = false
    @State private var showingNotificationToast: Bool = false
    @State private var habitForDirectLog: Habit?
    
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
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Header Summary
                    dailySummaryCard
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
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
                        LazyVStack(spacing: 12) {
                            ForEach(habits) { habit in
                                HabitCardView(
                                    habit: habit,
                                    onStartTimer: { targetHabit in
                                        timerViewModel.selectHabit(targetHabit)
                                        timerViewModel.start()
                                        selectedTab = 1 // Switch to Focus Timer tab
                                    },
                                    onDirectLog: { targetHabit in
                                        habitForDirectLog = targetHabit
                                    }
                                )
                                .contextMenu {
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
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
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
            .sheet(item: $habitForDirectLog) { habit in
                SessionCompletionSheet(
                    habit: habit,
                    durationMinutes: habit.targetMinutes,
                    onSaved: {}
                )
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
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.surface)
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(AppTheme.textPrimary)
                        .frame(width: max(0, geo.size.width * CGFloat(progressRatio)), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progressRatio)
                }
            }
            .frame(height: 8)
        }
        .padding(18)
        .bentoCard()
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(AppTheme.textSecondary)
            
            Text("No Habits Yet")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Tap the '+' button above to add your first technical habit.")
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .bentoCard()
    }
    
    // MARK: - Helpers
    private var todayFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    private func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        try? modelContext.save()
    }
    
    private func triggerTestNotification() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        NotificationManager.shared.sendTestNotification(delaySeconds: 2) {
            withAnimation(.spring()) {
                showingNotificationToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut) {
                    showingNotificationToast = false
                }
            }
        }
    }
}
