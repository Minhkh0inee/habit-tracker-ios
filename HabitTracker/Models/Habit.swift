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
