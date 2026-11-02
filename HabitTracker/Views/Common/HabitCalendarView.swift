import SwiftUI
import SwiftData

public struct HabitCalendarView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var habits: [Habit]
    
    @Query(filter: #Predicate<HabitSession> { $0.isCompleted })
    private var sessions: [HabitSession]
    
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    
    private let calendar = Calendar.current
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 14) {
            // Month Header with navigation buttons
            HStack {
                Text(monthYearString(from: displayedMonth))
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 30, height: 30)
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 30, height: 30)
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            
            // Weekday symbols
            let weekdayHeaders = ["S", "M", "T", "W", "T", "F", "S"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekdayHeaders.indices, id: \.self) { index in
                    Text(weekdayHeaders[index])
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Days Grid
            let days = daysInDisplayedMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        // Empty placeholder slot before month start
                        Color.clear
                            .frame(height: 38)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("100% Done")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .stroke(Color.primary.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 8, height: 8)
                    Text("Partial")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(AppTheme.textPrimary, lineWidth: 1)
                        .frame(width: 8, height: 8)
                    Text("Today")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
            .padding(.top, 4)
            .padding(.horizontal, 4)
        }
        .padding(16)
        .bentoCard()
    }
    
    // MARK: - Day Cell
    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()
        let completion = completionStatus(for: date)
        let dayNumber = calendar.component(.day, from: date)
        
        ZStack {
            // Background fill
            if completion.isHundredPercent {
                // 100% completed: Solid vibrant green circle
                Circle()
                    .fill(Color.green)
                    .shadow(color: Color.green.opacity(0.3), radius: 3, x: 0, y: 1)
                
                if isToday {
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                }
            } else if completion.hasPartialProgress && !isFuture {
                // Partial progress: subtle background ring
                Circle()
                    .stroke(Color.primary.opacity(0.35), lineWidth: 1.5)
            } else if isToday {
                // Today indicator: crisp border
                Circle()
                    .stroke(AppTheme.textPrimary, lineWidth: 1.5)
            }
            
            // Day Number Text
            VStack(spacing: 1) {
                Text("\(dayNumber)")
                    .font(.system(size: 13, weight: (isToday || completion.isHundredPercent) ? .bold : .regular, design: .rounded))
                    .foregroundColor(
                        completion.isHundredPercent ? .white :
                        isFuture ? AppTheme.textTertiary :
                        AppTheme.textPrimary
                    )
            }
        }
        .frame(height: 38)
    }
    
    // MARK: - Completion Status Calculation
    private struct DayCompletion {
        let completedCount: Int
        let totalCount: Int
        let isHundredPercent: Bool
        let hasPartialProgress: Bool
    }
    
    private func completionStatus(for date: Date) -> DayCompletion {
        guard !habits.isEmpty else {
            return DayCompletion(completedCount: 0, totalCount: 0, isHundredPercent: false, hasPartialProgress: false)
        }
        
        // Find completed sessions on this calendar day
        let daySessions = sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }
        
        // Find distinct habit IDs completed on this day
        let completedHabitIds = Set(daySessions.compactMap { $0.habit?.id })
        let completedCount = completedHabitIds.count
        let totalCount = habits.count
        
        let isHundred = completedCount >= totalCount && totalCount > 0
        let isPartial = completedCount > 0 && !isHundred
        
        return DayCompletion(
            completedCount: completedCount,
            totalCount: totalCount,
            isHundredPercent: isHundred,
            hasPartialProgress: isPartial
        )
    }
    
    // MARK: - Helpers
    private func monthYearString(from date: Date) -> String {
        AppFormatters.monthYear(date)
    }
    
    private func previousMonth() {
        if let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = prev
        }
    }
    
    private func nextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = next
        }
    }
    
    private func daysInDisplayedMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let daysRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth) // 1 = Sunday
        
        var result: [Date?] = []
        
        // Add leading empty slots
        for _ in 1..<weekdayOfFirstDay {
            result.append(nil)
        }
        
        // Add days of the month
        for day in daysRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                result.append(date)
            }
        }
        
        return result
    }
}
