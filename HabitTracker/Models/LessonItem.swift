import Foundation
import SwiftData

@Model
public final class LessonItem {
    public var id: UUID
    public var title: String
    public var notes: String
    public var category: String
    public var createdAt: Date
    
    // MARK: - Spaced Repetition Data
    public var reviewStage: Int
    public var nextReviewDate: Date
    public var reviewCount: Int
    public var isMastered: Bool
    
    public var session: HabitSession?
    public var habit: Habit?
    
    public init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        category: String = "General",
        createdAt: Date = Date(),
        reviewStage: Int = 0,
        nextReviewDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86400),
        reviewCount: Int = 0,
        isMastered: Bool = false,
        session: HabitSession? = nil,
        habit: Habit? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.category = category
        self.createdAt = createdAt
        self.reviewStage = reviewStage
        self.nextReviewDate = nextReviewDate
        self.reviewCount = reviewCount
        self.isMastered = isMastered
        self.session = session
        self.habit = habit
    }
    
    // MARK: - Spaced Repetition Leitner Intervals
    public func advanceReviewStage() {
        reviewCount += 1
        reviewStage = min(reviewStage + 1, 5)
        
        if reviewStage >= 5 {
            isMastered = true
        }
        
        let daysToAdd: Int
        switch reviewStage {
        case 1: daysToAdd = 3   // Stage 1 -> Review in 3 days
        case 2: daysToAdd = 7   // Stage 2 -> Review in 1 week
        case 3: daysToAdd = 14  // Stage 3 -> Review in 2 weeks
        case 4: daysToAdd = 30  // Stage 4 -> Review in 1 month
        default: daysToAdd = 60 // Stage 5 -> Mastered
        }
        
        nextReviewDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date().addingTimeInterval(Double(daysToAdd * 86400))
    }
    
    public func resetReviewStage() {
        reviewCount += 1
        reviewStage = 1
        isMastered = false
        // Reset to review tomorrow
        nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86400)
    }
}
