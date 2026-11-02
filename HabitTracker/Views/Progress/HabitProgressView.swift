import SwiftUI
import SwiftData
import Charts

public struct HabitProgressView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.createdAt)
    private var habits: [Habit]
    
    @Query(filter: #Predicate<HabitSession> { $0.isCompleted }, sort: \HabitSession.date, order: .reverse)
    private var sessions: [HabitSession]
    
    @State private var timeRangeDays: Int = 7
    @State private var expandedHabitIds: Set<UUID> = []
    @State private var showingRecallSheet: Bool = false
    
    public init() {}
    
    // MARK: - Overall Stats
    private var totalFocusMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    private var totalFocusHours: Double {
        Double(totalFocusMinutes) / 60.0
    }
    
    private var totalSessionsCount: Int {
        sessions.count
    }
    
    // MARK: - Daily Chart Data
    private struct DailyChartData: Identifiable {
        let id: String // Day label e.g. "Mon"
        let date: Date
        let dayLabel: String
        let totalMinutes: Int
    }
    
    private var chartPoints: [DailyChartData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var points: [DailyChartData] = []
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        
        for i in (0..<timeRangeDays).reversed() {
            guard let targetDate = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            let minutesOnDay = sessions.filter { session in
                calendar.isDate(session.date, inSameDayAs: targetDate)
            }.reduce(0) { $0 + $1.durationMinutes }
            
            let label = calendar.isDateInToday(targetDate) ? "Today" : dayFormatter.string(from: targetDate)
            
            points.append(DailyChartData(
                id: "\(i)_\(label)",
                date: targetDate,
                dayLabel: label,
                totalMinutes: minutesOnDay
            ))
        }
        
        return points
    }
    
    private var averageDailyMinutes: Int {
        guard !chartPoints.isEmpty else { return 0 }
        let sum = chartPoints.reduce(0) { $0 + $1.totalMinutes }
        return sum / chartPoints.count
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    // Top Overview Metrics
                    overviewMetricsHeader
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Focus Trend Line Chart Card
                    focusTrendChartCard
                        .padding(.horizontal)
                    
                    // Habits Process Breakdown & Checklist
                    habitProcessSection
                        .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Progress & Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingRecallSheet = true }) {
                        HStack(spacing: 5) {
                            Image(systemName: "brain.head.profile")
                            Text("Interview Recall")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingRecallSheet) {
                InterviewRecallView()
            }
        }
    }
    
    // MARK: - Overview Metrics Header
    private var overviewMetricsHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL HOURS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                Text(String(format: "%.1fh", totalFocusHours))
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .bentoCard()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("SESSIONS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(totalSessionsCount)")
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .bentoCard()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("DAILY AVG")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(averageDailyMinutes)m")
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .bentoCard()
        }
    }
    
    // MARK: - Line Chart Card
    private var focusTrendChartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("FOCUS TIME TREND")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Daily Learning Minutes")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                // 7d vs 14d Picker
                Picker("Range", selection: $timeRangeDays) {
                    Text("7D").tag(7)
                    Text("14D").tag(14)
                }
                .pickerStyle(.segmented)
                .frame(width: 110)
            }
            
            // Native SwiftUI Line Chart
            Chart {
                ForEach(chartPoints) { point in
                    AreaMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Minutes", point.totalMinutes)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                AppTheme.textPrimary.opacity(0.18),
                                AppTheme.textPrimary.opacity(0.01)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Minutes", point.totalMinutes)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    
                    PointMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Minutes", point.totalMinutes)
                    )
                    .foregroundStyle(AppTheme.textPrimary)
                    .symbolSize(32)
                }
            }
            .frame(height: 190)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        .foregroundStyle(AppTheme.border)
                    AxisValueLabel()
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        .foregroundStyle(AppTheme.border)
                    AxisValueLabel {
                        if let mins = value.as(Int.self) {
                            Text("\(mins)m")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(18)
        .bentoCard()
    }
    
    // MARK: - Habit Process & Checklist Section
    private var habitProcessSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Habit Mastery & Process")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(habits.count) Active Habits")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            LazyVStack(spacing: 14) {
                ForEach(habits) { habit in
                    habitProcessCard(habit)
                }
            }
        }
    }
    
    // MARK: - Individual Habit Process Card (with Expandable Session Checklist)
    private func habitProcessCard(_ habit: Habit) -> some View {
        let isExpanded = expandedHabitIds.contains(habit.id)
        let habitSessions = sessions.filter { $0.habit?.id == habit.id }
        let totalMinutes = habitSessions.reduce(0) { $0 + $1.durationMinutes }
        let totalHours = Double(totalMinutes) / 60.0
        
        // Tier Milestones: 5h, 15h, 30h, 50h, 100h
        let milestoneTargetHours: Double = totalHours < 5 ? 5 :
                                          totalHours < 15 ? 15 :
                                          totalHours < 30 ? 30 :
                                          totalHours < 50 ? 50 : 100
        let progressPercent = min(totalHours / milestoneTargetHours, 1.0)
        
        return VStack(spacing: 0) {
            // Header: Habit Overview
            Button(action: {
                withAnimation(.easeInOut(duration: 0.22)) {
                    if isExpanded {
                        expandedHabitIds.remove(habit.id)
                    } else {
                        expandedHabitIds.insert(habit.id)
                    }
                }
            }) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: habit.iconName)
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.category.uppercased())
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Text(habit.title)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.1fh", totalHours))
                                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("\(habitSessions.count) sessions")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .padding(.leading, 4)
                    }
                    
                    // Milestone Progress Bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Goal: \(Int(milestoneTargetHours))h Milestone")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text("\(Int(progressPercent * 100))%")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppTheme.surface)
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(AppTheme.textPrimary)
                                    .frame(width: max(0, geo.size.width * CGFloat(progressPercent)), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)
            
            // Expandable Checklist of Completed Sessions for this Habit
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                        .background(AppTheme.border)
                        .padding(.horizontal, 14)
                    
                    Text("COMPLETED SESSIONS CHECKLIST")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.top, 4)
                    
                    if habitSessions.isEmpty {
                        Text("No sessions completed yet for this habit.")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 8)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(habitSessions) { session in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.green)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        let titleText = !session.lessonTitle.isEmpty ? session.lessonTitle : formattedDate(session.date)
                                        Text(titleText)
                                            .font(.system(.caption, design: .rounded, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        let noteSnippet = !session.lessonNotes.isEmpty ? session.lessonNotes : session.notes
                                        if !noteSnippet.isEmpty {
                                            Text(noteSnippet)
                                                .font(.system(size: 11, design: .rounded))
                                                .foregroundColor(AppTheme.textSecondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(session.durationMinutes)m")
                                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.surface)
                                        .clipShape(Capsule())
                                }
                                .padding(10)
                                .background(AppTheme.surface.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 14)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .bentoCard()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}
