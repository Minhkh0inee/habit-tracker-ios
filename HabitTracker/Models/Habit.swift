import Foundation
import SwiftData

@Model
public final class Habit {
    public var id: UUID
    public var title: String
    public var category: String
    public var targetMinutes: Int
    public var iconName: String
    public var isArchived: Bool
    public var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \HabitSession.habit)
    public var sessions: [HabitSession] = []
    
    @Relationship(deleteRule: .cascade, inverse: \CurriculumConcept.habit)
    public var curriculumQueue: [CurriculumConcept] = []
    
    public init(
        id: UUID = UUID(),
        title: String,
        category: String = "General",
        targetMinutes: Int = 30,
        iconName: String = "checklist",
        isArchived: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.targetMinutes = targetMinutes
        self.iconName = iconName
        self.isArchived = isArchived
        self.createdAt = createdAt
    }
    
    // MARK: - Computed Properties for Today
    public var completedSessionsToday: [HabitSession] {
        let calendar = Calendar.current
        return sessions.filter { session in
            session.isCompleted && calendar.isDateInToday(session.date)
        }
    }
    
    public var isCompletedToday: Bool {
        !completedSessionsToday.isEmpty
    }
    
    public var totalMinutesToday: Int {
        completedSessionsToday.reduce(0) { $0 + $1.durationMinutes }
    }
    
    // MARK: - Streak Computations
    public var completedSessionDates: [Date] {
        sessions
            .filter { $0.isCompleted }
            .map { $0.date }
    }

    public var streakInfo: StreakInfo {
        StreakEngine.streakInfo(from: completedSessionDates)
    }

    public var currentStreak: Int {
        streakInfo.currentStreak
    }

    public var longestStreak: Int {
        streakInfo.longestStreak
    }

    public var streakIsActiveToday: Bool {
        streakInfo.isActiveToday
    }
    
    // MARK: - Curriculum Roadmap & Daily Rollover Queue
    public var uncompletedCurriculum: [CurriculumConcept] {
        curriculumQueue
            .filter { !$0.isCompleted }
            .sorted { $0.orderIndex < $1.orderIndex }
    }
    
    public var completedCurriculum: [CurriculumConcept] {
        curriculumQueue
            .filter { $0.isCompleted }
            .sorted { ($0.completedDate ?? Date.distantPast) > ($1.completedDate ?? Date.distantPast) }
    }
    
    public var completedCurriculumToday: [CurriculumConcept] {
        let calendar = Calendar.current
        return curriculumQueue.filter { concept in
            concept.isCompleted && concept.completedDate != nil && calendar.isDateInToday(concept.completedDate!)
        }.sorted { ($0.completedDate ?? .distantPast) < ($1.completedDate ?? .distantPast) }
    }
    
    /// Selects the concepts fitting today's target time, with automatic rollover for past-due uncompleted items
    public var todayScheduledConcepts: [CurriculumConcept] {
        let uncompleted = uncompletedCurriculum
        guard !uncompleted.isEmpty else { return [] }
        
        let completedMinutesToday = completedCurriculumToday.reduce(0) { $0 + $1.estimatedMinutes }
        let remainingTargetMinutes = max(0, targetMinutes - completedMinutesToday)
        
        // If daily target minutes are already met by completed concepts today, no extra uncompleted concepts are needed
        guard remainingTargetMinutes > 0 else { return [] }
        
        var selected: [CurriculumConcept] = []
        var accumulatedMinutes = 0
        
        for concept in uncompleted {
            selected.append(concept)
            accumulatedMinutes += concept.estimatedMinutes
            // Stop once we meet or exceed the habit's remaining target minutes
            if accumulatedMinutes >= remainingTargetMinutes {
                break
            }
        }
        
        return selected
    }
    
    public var todayAllGoals: [CurriculumConcept] {
        completedCurriculumToday + todayScheduledConcepts
    }
    
    public var todayScheduledMinutes: Int {
        todayScheduledConcepts.reduce(0) { $0 + $1.estimatedMinutes }
    }
    
    // MARK: - Default Presets
    public static var defaultTechHabits: [Habit] {
        [
            Habit(
                title: "Data Structures & Algorithms",
                category: "Computer Science",
                targetMinutes: 45,
                iconName: "point.3.connected.trianglepath.dotted"
            ),
            Habit(
                title: "Swift & iOS Development",
                category: "Mobile",
                targetMinutes: 45,
                iconName: "swift"
            ),
            Habit(
                title: "System Design",
                category: "Architecture",
                targetMinutes: 30,
                iconName: "network"
            ),
            Habit(
                title: "Data Engineering (DE)",
                category: "Data",
                targetMinutes: 45,
                iconName: "cylinder.split.1x2"
            ),
            Habit(
                title: "Python for DE & Tools",
                category: "Languages & Tools",
                targetMinutes: 30,
                iconName: "terminal"
            ),
            Habit(
                title: "Coding & Side Projects",
                category: "Development",
                targetMinutes: 60,
                iconName: "chevron.left.forwardslash.chevron.right"
            )
        ]
    }
}
