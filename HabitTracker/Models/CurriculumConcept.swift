import Foundation
import SwiftData

@Model
public final class CurriculumConcept {
    public var id: UUID
    public var title: String
    public var conceptDescription: String
    public var category: String
    public var estimatedMinutes: Int
    public var orderIndex: Int
    public var isCompleted: Bool
    public var completedDate: Date?
    public var isRolledOver: Bool
    public var isAISynced: Bool
    public var createdAt: Date
    
    public var habit: Habit?
    
    public init(
        id: UUID = UUID(),
        title: String,
        conceptDescription: String = "",
        category: String = "General",
        estimatedMinutes: Int = 25,
        orderIndex: Int = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        isRolledOver: Bool = false,
        isAISynced: Bool = false,
        createdAt: Date = Date(),
        habit: Habit? = nil
    ) {
        self.id = id
        self.title = title
        self.conceptDescription = conceptDescription
        self.category = category
        self.estimatedMinutes = estimatedMinutes
        self.orderIndex = orderIndex
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.isRolledOver = isRolledOver
        self.isAISynced = isAISynced
        self.createdAt = createdAt
        self.habit = habit
    }
}
