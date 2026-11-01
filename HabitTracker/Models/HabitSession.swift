import Foundation
import SwiftData

@Model
public final class HabitSession {
    public var id: UUID
    public var startTime: Date
    public var endTime: Date
    public var durationMinutes: Int
    public var isCompleted: Bool
    public var photoFileName: String?
    public var notes: String
    public var date: Date
    
    // MARK: - Study Lesson & Concept Data (for Spaced Repetition & Interview Prep)
    public var lessonTitle: String = ""
    public var lessonNotes: String = ""
    public var reviewStage: Int = 0
    public var nextReviewDate: Date? = nil
    public var reviewCount: Int = 0
    public var isMastered: Bool = false
    
    // Individual itemized concepts learned in this session
    @Relationship(deleteRule: .cascade, inverse: \LessonItem.session)
    public var lessonItems: [LessonItem] = []
    
    public var habit: Habit?
    
    public init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date = Date(),
        durationMinutes: Int = 0,
        isCompleted: Bool = true,
        photoFileName: String? = nil,
        notes: String = "",
        lessonTitle: String = "",
        lessonNotes: String = "",
        reviewStage: Int = 0,
        nextReviewDate: Date? = nil,
        reviewCount: Int = 0,
        isMastered: Bool = false,
        lessonItems: [LessonItem] = [],
        date: Date = Date(),
        habit: Habit? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = durationMinutes
        self.isCompleted = isCompleted
        self.photoFileName = photoFileName
        self.notes = notes
        self.lessonTitle = lessonTitle
        self.lessonNotes = lessonNotes.isEmpty ? notes : lessonNotes
        self.reviewStage = reviewStage
        self.nextReviewDate = nextReviewDate
        self.reviewCount = reviewCount
        self.isMastered = isMastered
        self.lessonItems = lessonItems
        self.date = date
        self.habit = habit
    }
    
    // MARK: - Spaced Repetition Helpers
    public static func calculateNextReviewDate(from stage: Int) -> Date {
        let calendar = Calendar.current
        let daysToAdd: Int
        switch stage {
        case 0: daysToAdd = 1   // Review tomorrow
        case 1: daysToAdd = 3   // Review in 3 days
        case 2: daysToAdd = 7   // Review in 1 week
        case 3: daysToAdd = 14  // Review in 2 weeks
        default: daysToAdd = 30 // Monthly revision / interview-ready
        }
        return calendar.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date().addingTimeInterval(86400)
    }
}
