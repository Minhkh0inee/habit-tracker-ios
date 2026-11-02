import Foundation

/// Centralized Leitner Spaced Repetition interval engine
public enum SpacedRepetitionScheduler {
    /// Returns the target next review date calculated from the current review stage
    /// Stages: 0 (Day 1) -> 1 (Day 3) -> 2 (Day 7) -> 3 (Day 14) -> 4 (Day 30) -> 5+ (Day 60)
    public static func calculateNextReviewDate(from currentStage: Int, referenceDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        let daysToAdd: Int
        switch currentStage {
        case 0: daysToAdd = 1   // 1 day review
        case 1: daysToAdd = 3   // 3 days review
        case 2: daysToAdd = 7   // 1 week review
        case 3: daysToAdd = 14  // 2 weeks review
        case 4: daysToAdd = 30  // 1 month review
        default: daysToAdd = 60 // 2 months maintenance
        }
        return calendar.date(byAdding: .day, value: daysToAdd, to: referenceDate) ?? referenceDate
    }
    
    /// User-friendly label for current review stage
    public static func stageTitle(for stage: Int) -> String {
        if stage >= 5 {
            return "Stage 5 (Mastered)"
        } else if stage == 0 {
            return "New (Stage 0)"
        } else {
            return "Stage \(stage)/5"
        }
    }
}
