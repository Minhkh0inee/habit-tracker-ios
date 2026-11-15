import XCTest
@testable import HabitTracker

final class SpacedRepetitionSchedulerTests: XCTestCase {
    private var calendar: Calendar!
    private var baseDate: Date!
    
    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
        
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 11
        comps.day = 15
        comps.hour = 12
        comps.minute = 0
        comps.second = 0
        comps.timeZone = cal.timeZone
        baseDate = cal.date(from: comps)!
    }
    
    override func tearDown() {
        calendar = nil
        baseDate = nil
        super.tearDown()
    }
    
    func testLeitnerIntervals() {
        // Stage 0: 1 day review
        let date0 = SpacedRepetitionScheduler.calculateNextReviewDate(from: 0, referenceDate: baseDate)
        let days0 = calendar.dateComponents([.day], from: baseDate, to: date0).day
        XCTAssertEqual(days0, 1)
        
        // Stage 1: 3 days review
        let date1 = SpacedRepetitionScheduler.calculateNextReviewDate(from: 1, referenceDate: baseDate)
        let days1 = calendar.dateComponents([.day], from: baseDate, to: date1).day
        XCTAssertEqual(days1, 3)
        
        // Stage 2: 7 days (1 week) review
        let date2 = SpacedRepetitionScheduler.calculateNextReviewDate(from: 2, referenceDate: baseDate)
        let days2 = calendar.dateComponents([.day], from: baseDate, to: date2).day
        XCTAssertEqual(days2, 7)
        
        // Stage 3: 14 days (2 weeks) review
        let date3 = SpacedRepetitionScheduler.calculateNextReviewDate(from: 3, referenceDate: baseDate)
        let days3 = calendar.dateComponents([.day], from: baseDate, to: date3).day
        XCTAssertEqual(days3, 14)
        
        // Stage 4: 30 days (1 month) review
        let date4 = SpacedRepetitionScheduler.calculateNextReviewDate(from: 4, referenceDate: baseDate)
        let days4 = calendar.dateComponents([.day], from: baseDate, to: date4).day
        XCTAssertEqual(days4, 30)
        
        // Stage 5+: 60 days (2 months maintenance)
        let date5 = SpacedRepetitionScheduler.calculateNextReviewDate(from: 5, referenceDate: baseDate)
        let days5 = calendar.dateComponents([.day], from: baseDate, to: date5).day
        XCTAssertEqual(days5, 60)
        
        let date10 = SpacedRepetitionScheduler.calculateNextReviewDate(from: 10, referenceDate: baseDate)
        let days10 = calendar.dateComponents([.day], from: baseDate, to: date10).day
        XCTAssertEqual(days10, 60)
    }
    
    func testStageTitles() {
        XCTAssertEqual(SpacedRepetitionScheduler.stageTitle(for: 0), "New (Stage 0)")
        XCTAssertEqual(SpacedRepetitionScheduler.stageTitle(for: 1), "Stage 1/5")
        XCTAssertEqual(SpacedRepetitionScheduler.stageTitle(for: 2), "Stage 2/5")
        XCTAssertEqual(SpacedRepetitionScheduler.stageTitle(for: 3), "Stage 3/5")
        XCTAssertEqual(SpacedRepetitionScheduler.stageTitle(for: 4), "Stage 4/5")
        XCTAssertEqual(SpacedRepetitionScheduler.stageTitle(for: 5), "Stage 5 (Mastered)")
        XCTAssertEqual(SpacedRepetitionScheduler.stageTitle(for: 8), "Stage 5 (Mastered)")
    }
    
    func testLessonItemStageProgression() {
        let item = LessonItem(title: "Swift 6 Concurrency", notes: "Actor Isolation")
        XCTAssertEqual(item.reviewStage, 0)
        XCTAssertFalse(item.isMastered)
        XCTAssertEqual(item.reviewCount, 0)
        
        // Advance 1
        item.advanceReviewStage()
        XCTAssertEqual(item.reviewStage, 1)
        XCTAssertEqual(item.reviewCount, 1)
        XCTAssertFalse(item.isMastered)
        
        // Advance to 5
        item.advanceReviewStage() // 2
        item.advanceReviewStage() // 3
        item.advanceReviewStage() // 4
        item.advanceReviewStage() // 5
        XCTAssertEqual(item.reviewStage, 5)
        XCTAssertTrue(item.isMastered)
        
        // Reset when user struggled
        item.resetReviewStage()
        XCTAssertEqual(item.reviewStage, 1)
        XCTAssertFalse(item.isMastered)
        XCTAssertEqual(item.reviewCount, 6)
    }
}
