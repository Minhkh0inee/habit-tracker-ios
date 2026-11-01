import SwiftUI
import SwiftData

public struct HistoryView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var habits: [Habit]
    
    @Query(sort: \HabitSession.endTime, order: .reverse)
    private var sessions: [HabitSession]
    
    @State private var selectedSession: HabitSession?
    @State private var collapsedDates: Set<Date> = []
    
    public init() {}
    
    private var totalHoursLearned: Double {
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        return Double(totalMinutes) / 60.0
    }
    
    // Group sessions by calendar day
    private struct DateGroup: Identifiable {
        let id: Date // startOfDay
        let date: Date
        let sessions: [HabitSession]
        
        var totalMinutes: Int {
            sessions.reduce(0) { $0 + $1.durationMinutes }
        }
    }
    
    private var groupedSessions: [DateGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        
        return grouped.keys.sorted(by: >).compactMap { startOfDay in
            guard let items = grouped[startOfDay] else { return nil }
            return DateGroup(
                id: startOfDay,
                date: items.first?.date ?? startOfDay,
                sessions: items.sorted { $0.endTime > $1.endTime }
            )
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Monthly Activity Calendar Section
                    HabitCalendarView()
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Stats Summary Header
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SESSIONS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("\(sessions.count)")
                                .font(.system(.title2, design: .monospaced, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .bentoCard()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("HOURS LOGGED")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                            Text(String(format: "%.1fh", totalHoursLearned))
                                .font(.system(.title2, design: .monospaced, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .bentoCard()
                    }
                    .padding(.horizontal)
                    
                    // Grouped History Feed
                    if sessions.isEmpty {
                        emptyStateView
                            .padding(.horizontal)
                            .padding(.top, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Daily Proof Logs")
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                Button(action: toggleAllCollapsed) {
                                    Text(collapsedDates.isEmpty ? "Collapse All" : "Expand All")
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(groupedSessions) { group in
                                    dateGroupCard(group)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Proof Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedSession) { session in
                SessionDetailSheet(session: session)
            }
        }
    }
    
    // MARK: - Big Date Group Card (Collapsible)
    private func dateGroupCard(_ group: DateGroup) -> some View {
        let isCollapsed = collapsedDates.contains(group.id)
        let distinctHabitsDone = Set(group.sessions.compactMap { $0.habit?.id }).count
        let isHundred = !habits.isEmpty && distinctHabitsDone >= habits.count
        
        return VStack(spacing: 0) {
            // Big Card Header (Tap to Collapse / Expand)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.22)) {
                    if isCollapsed {
                        collapsedDates.remove(group.id)
                    } else {
                        collapsedDates.insert(group.id)
                    }
                }
            }) {
                HStack(spacing: 12) {
                    // Date indicator icon
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(formatGroupHeaderDate(group.date))
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("\(group.sessions.count) completed • \(group.totalMinutes)m focus")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // 100% Badge (if achieved)
                    if isHundred {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("100%")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.green)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    // Chevron indicating expand / collapse
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                        .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                        .padding(.leading, 4)
                }
                .padding(14)
            }
            .buttonStyle(.plain)
            
            // Collapsible Content (Wrapped cards for that date)
            if !isCollapsed {
                VStack(spacing: 12) {
                    Divider()
                        .background(AppTheme.border)
                        .padding(.horizontal, 14)
                    
                    VStack(spacing: 10) {
                        ForEach(group.sessions) { session in
                            Button(action: { selectedSession = session }) {
                                sessionInnerCard(session)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .bentoCard()
    }
    
    // MARK: - Individual Session Item Inside Date Card
    private func sessionInnerCard(_ session: HabitSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // Habit Icon
                Image(systemName: session.habit?.iconName ?? "checkmark.seal")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(session.habit?.title ?? "Completed Habit")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(formatTimeOnly(session.endTime))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Text("\(session.durationMinutes)m")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundColor(AppTheme.buttonForeground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.buttonBackground)
                    .clipShape(Capsule())
            }
            
            // Proof Image Preview (if present)
            if let photoName = session.photoFileName,
               let image = ImageStorageService.shared.loadProofImage(named: photoName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            }
            
            // Lesson Concept & Notes Snippet
            if !session.lessonTitle.isEmpty {
                Text("Concept: \(session.lessonTitle)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            let displayNotes = !session.lessonNotes.isEmpty ? session.lessonNotes : session.notes
            if !displayNotes.isEmpty {
                Text(displayNotes)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(AppTheme.textSecondary)
            
            Text("No Proof Logs Yet")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Complete your first study session or checklist item and snap a photo to build your proof gallery.")
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .bentoCard()
    }
    
    // MARK: - Helpers
    private func toggleAllCollapsed() {
        withAnimation(.easeInOut(duration: 0.22)) {
            if collapsedDates.isEmpty {
                // Collapse all
                collapsedDates = Set(groupedSessions.map { $0.id })
            } else {
                // Expand all
                collapsedDates.removeAll()
            }
        }
    }
    
    private func formatGroupHeaderDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "MMM d, yyyy"
            return "Today • \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "MMM d, yyyy"
            return "Yesterday • \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "EEEE • MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
    
    private func formatTimeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
