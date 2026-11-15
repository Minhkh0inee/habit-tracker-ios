import XCTest
@testable import HabitTracker

final class StreakEngineTests: XCTestCase {
    private var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
    }
    
    override func tearDown() {
        calendar = nil
        super.tearDown()
    }
    
    // Helper to make a date at midnight in UTC
    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = 0
        comps.second = 0
        comps.timeZone = calendar.timeZone
        return calendar.date(from: comps)!
    }
    
    func testZeroSessions_ReturnsZeroStreak() {
        let info = StreakEngine.streakInfo(from: [], calendar: calendar)
        XCTAssertEqual(info.currentStreak, 0)
        XCTAssertEqual(info.longestStreak, 0)
        XCTAssertNil(info.lastActiveDate)
        XCTAssertFalse(info.isActiveToday)
        XCTAssertFalse(info.isAtRisk)
        XCTAssertEqual(info.status, .none)
    }
    
    func testSingleSessionToday_ReturnsOneDayStreak() {
        let today = calendar.startOfDay(for: Date())
        let info = StreakEngine.streakInfo(from: [today], calendar: calendar)
        
        XCTAssertEqual(info.currentStreak, 1)
        XCTAssertEqual(info.longestStreak, 1)
        XCTAssertTrue(info.isActiveToday)
        XCTAssertFalse(info.isAtRisk)
        XCTAssertEqual(info.status, .building)
    }
    
    func testMultipleSessionsOnSameDay_CountAsSingleDayStreak() {
        let today = calendar.startOfDay(for: Date())
        let session1 = today.addingTimeInterval(3600)
        let session2 = today.addingTimeInterval(7200)
        let session3 = today.addingTimeInterval(14400)
        
        let info = StreakEngine.streakInfo(from: [session1, session2, session3], calendar: calendar)
        XCTAssertEqual(info.currentStreak, 1)
        XCTAssertEqual(info.longestStreak, 1)
        XCTAssertTrue(info.isActiveToday)
    }
    
    func testConsecutiveDaysStreak_AndTiers() {
        let today = calendar.startOfDay(for: Date())
        
        // 5 consecutive days -> Building
        var dates5: [Date] = []
        for i in 0..<5 {
            dates5.append(calendar.date(byAdding: .day, value: -i, to: today)!)
        }
        let info5 = StreakEngine.streakInfo(from: dates5, calendar: calendar)
        XCTAssertEqual(info5.currentStreak, 5)
        XCTAssertEqual(info5.status, .building)
        
        // 7 consecutive days -> Hot
        var dates7: [Date] = []
        for i in 0..<7 {
            dates7.append(calendar.date(byAdding: .day, value: -i, to: today)!)
        }
        let info7 = StreakEngine.streakInfo(from: dates7, calendar: calendar)
        XCTAssertEqual(info7.currentStreak, 7)
        XCTAssertEqual(info7.status, .hot)
        
        // 14 consecutive days -> Blazing
        var dates14: [Date] = []
        for i in 0..<14 {
            dates14.append(calendar.date(byAdding: .day, value: -i, to: today)!)
        }
        let info14 = StreakEngine.streakInfo(from: dates14, calendar: calendar)
        XCTAssertEqual(info14.currentStreak, 14)
        XCTAssertEqual(info14.status, .blazing)
        
        // 30 consecutive days -> Legendary
        var dates30: [Date] = []
        for i in 0..<30 {
            dates30.append(calendar.date(byAdding: .day, value: -i, to: today)!)
        }
        let info30 = StreakEngine.streakInfo(from: dates30, calendar: calendar)
        XCTAssertEqual(info30.currentStreak, 30)
        XCTAssertEqual(info30.status, .legendary)
    }
    
    func testBrokenStreak_PreservesLongestStreak() {
        let today = calendar.startOfDay(for: Date())
        
        // 10 days active, then a 3-day gap, then 2 days active up to today
        var dates: [Date] = []
        // Current 2 days
        dates.append(today)
        dates.append(calendar.date(byAdding: .day, value: -1, to: today)!)
        
        // Gap on days -2, -3, -4
        // Old 10-day streak on days -5 through -14
        for i in 5...14 {
            dates.append(calendar.date(byAdding: .day, value: -i, to: today)!)
        }
        
        let info = StreakEngine.streakInfo(from: dates, calendar: calendar)
        XCTAssertEqual(info.currentStreak, 2)
        XCTAssertEqual(info.longestStreak, 10)
    }
    
    func testAtRiskState_WhenCompletedYesterdayButNotToday() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!
        
        let info = StreakEngine.streakInfo(from: [yesterday, dayBeforeYesterday], calendar: calendar)
        XCTAssertEqual(info.currentStreak, 2)
        XCTAssertFalse(info.isActiveToday)
        XCTAssertTrue(info.isAtRisk)
    }
    
    func testGlobalStreakInfo_AggregatesAcrossMultipleHabits() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let habit1ID = UUID()
        let habit2ID = UUID()
        
        // Habit 1 was done yesterday, Habit 2 was done today
        let dict: [UUID: [Date]] = [
            habit1ID: [yesterday],
            habit2ID: [today]
        ]
        
        let globalInfo = StreakEngine.globalStreakInfo(habitCompletedDates: dict, calendar: calendar)
        XCTAssertEqual(globalInfo.currentStreak, 2)
        XCTAssertTrue(globalInfo.isActiveToday)
        XCTAssertFalse(globalInfo.isAtRisk)
    }
    
    func testStreakStatusTransitions() {
        XCTAssertEqual(StreakStatus.from(streak: 0), .none)
        XCTAssertEqual(StreakStatus.from(streak: 1), .building)
        XCTAssertEqual(StreakStatus.from(streak: 6), .building)
        XCTAssertEqual(StreakStatus.from(streak: 7), .hot)
        XCTAssertEqual(StreakStatus.from(streak: 13), .hot)
        XCTAssertEqual(StreakStatus.from(streak: 14), .blazing)
        XCTAssertEqual(StreakStatus.from(streak: 29), .blazing)
        XCTAssertEqual(StreakStatus.from(streak: 30), .legendary)
        XCTAssertEqual(StreakStatus.from(streak: 100), .legendary)
    }
}
