import SwiftUI
import SwiftData

public struct TimerView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.createdAt)
    private var habits: [Habit]
    
    @Bindable public var viewModel: TimerViewModel
    @State private var showingHabitSelector: Bool = false
    
    public init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Habit Selector Card
                    habitHeaderCard
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Circular Countdown Timer
                    CircularProgressView(
                        progress: viewModel.progress,
                        timeString: viewModel.formattedRemainingTime,
                        habitTitle: viewModel.selectedHabit?.title ?? "Free Focus",
                        isRunning: viewModel.state == .running
                    )
                    .frame(maxWidth: 320)
                    .padding(.vertical, 8)
                    
                    // Quick Duration Preset Buttons (only active when idle)
                    if viewModel.state == .idle {
                        durationPresetsView
                            .padding(.horizontal)
                    }
                    
                    // Action Controls
                    actionButtonsView
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Focus Timer")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showCompletionSheet) {
                SessionCompletionSheet(
                    habit: viewModel.selectedHabit,
                    durationMinutes: viewModel.actualMinutesElapsed,
                    onSaved: {
                        viewModel.resetAfterCompletion()
                    }
                )
            }
            .sheet(isPresented: $showingHabitSelector) {
                habitPickerSheet
            }
            .onAppear {
                if viewModel.selectedHabit == nil, let first = habits.first {
                    viewModel.selectHabit(first)
                }
            }
        }
    }
    
    // MARK: - Habit Header Card
    private var habitHeaderCard: some View {
        Button(action: {
            if viewModel.state == .idle {
                showingHabitSelector = true
            }
        }) {
            HStack(spacing: 14) {
                Image(systemName: viewModel.selectedHabit?.iconName ?? "timer")
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.selectedHabit?.category.uppercased() ?? "FOCUS SESSION")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(viewModel.selectedHabit?.title ?? "Select Habit")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if viewModel.state == .idle {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(14)
            .bentoCard()
        }
        .buttonStyle(.plain)
        .disabled(viewModel.state != .idle)
    }
    
    // MARK: - Duration Presets
    private var durationPresetsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Session Duration")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            
            HStack(spacing: 8) {
                ForEach([15, 25, 45, 60], id: \.self) { minutes in
                    let isSelected = viewModel.selectedDurationMinutes == minutes
                    Button(action: {
                        viewModel.setDuration(minutes: minutes)
                    }) {
                        Text("\(minutes)m")
                            .font(.system(.subheadline, design: .rounded, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? AppTheme.buttonForeground : AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isSelected ? AppTheme.buttonBackground : AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            switch viewModel.state {
            case .idle:
                Button(action: { viewModel.start() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Start Focus")
                    }
                }
                .primaryButton()
                
            case .running:
                HStack(spacing: 12) {
                    Button(action: { viewModel.pause() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pause.fill")
                            Text("Pause")
                        }
                    }
                    .secondaryButton()
                    
                    Button(action: { viewModel.finishEarly() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                            Text("Finish & Proof")
                        }
                    }
                    .primaryButton()
                }
                
            case .paused:
                HStack(spacing: 12) {
                    Button(action: { viewModel.reset() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                    }
                    .secondaryButton()
                    
                    Button(action: { viewModel.resume() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Resume")
                        }
                    }
                    .primaryButton()
                }
                
            case .completed:
                Button(action: { viewModel.reset() }) {
                    Text("New Session")
                }
                .primaryButton()
            }
        }
    }
    
    // MARK: - Habit Selection Sheet
    private var habitPickerSheet: some View {
        NavigationStack {
            List(habits) { habit in
                Button(action: {
                    viewModel.selectHabit(habit)
                    showingHabitSelector = false
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: habit.iconName)
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.title)
                                .font(.system(.body, design: .rounded, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("\(habit.category) • \(habit.targetMinutes) min target")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        if viewModel.selectedHabit?.id == habit.id {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showingHabitSelector = false
                    }
                }
            }
        }
    }
}
