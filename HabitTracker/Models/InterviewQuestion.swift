import Foundation
import SwiftData

@Model
public final class InterviewQuestion {
    public var id: UUID
    public var category: String
    public var title: String
    public var question: String
    public var keyTakeaways: String
    public var companyTag: String
    public var difficulty: String
    public var isAISynced: Bool
    public var createdAt: Date
    
    // Spaced Repetition Revision
    public var reviewStage: Int
    public var nextReviewDate: Date?
    public var reviewCount: Int
    public var isMastered: Bool
    
    public init(
        id: UUID = UUID(),
        category: String,
        title: String,
        question: String,
        keyTakeaways: String = "",
        companyTag: String = "Tech Interview",
        difficulty: String = "Medium",
        isAISynced: Bool = true,
        createdAt: Date = Date(),
        reviewStage: Int = 0,
        nextReviewDate: Date? = nil,
        reviewCount: Int = 0,
        isMastered: Bool = false
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.question = question
        self.keyTakeaways = keyTakeaways
        self.companyTag = companyTag
        self.difficulty = difficulty
        self.isAISynced = isAISynced
        self.createdAt = createdAt
        self.reviewStage = reviewStage
        self.nextReviewDate = nextReviewDate
        self.reviewCount = reviewCount
        self.isMastered = isMastered
    }
}
