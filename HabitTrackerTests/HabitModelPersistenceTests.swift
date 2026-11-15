import XCTest
import SwiftData
@testable import HabitTracker

@MainActor
final class HabitModelPersistenceTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        let schema = Schema([
            Habit.self,
            HabitSession.self,
            LessonItem.self,
            InterviewQuestion.self,
            CurriculumConcept.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }
    
    override func tearDown() async throws {
        container = nil
        context = nil
        try await super.tearDown()
    }
    
    func testHabitCreationAndDefaultValues() throws {
        let habit = Habit(
            title: "Data Structures & Algorithms",
            category: "Computer Science",
            targetMinutes: 45,
            iconName: "point.3.connected.trianglepath.dotted"
        )
        context.insert(habit)
        try context.save()
        
        let fetched = try context.fetch(FetchDescriptor<Habit>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Data Structures & Algorithms")
        XCTAssertEqual(fetched.first?.targetMinutes, 45)
        XCTAssertFalse(fetched.first!.isCompletedToday)
        XCTAssertEqual(fetched.first?.totalMinutesToday, 0)
    }
    
    func testSessionLoggingAndTodayCalculations() throws {
        let habit = Habit(title: "Swift 6", category: "Mobile", targetMinutes: 30)
        context.insert(habit)
        
        let today = Date()
        let sessionToday = HabitSession(
            durationMinutes: 30,
            isCompleted: true,
            notes: "Studied Swift Concurrency",
            date: today,
            habit: habit
        )
        context.insert(sessionToday)
        habit.sessions.append(sessionToday)
        
        // Log a session from 3 days ago
        let oldDate = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let sessionOld = HabitSession(
            durationMinutes: 25,
            isCompleted: true,
            notes: "Old session",
            date: oldDate,
            habit: habit
        )
        context.insert(sessionOld)
        habit.sessions.append(sessionOld)
        
        try context.save()
        
        XCTAssertEqual(habit.sessions.count, 2)
        XCTAssertEqual(habit.completedSessionsToday.count, 1)
        XCTAssertTrue(habit.isCompletedToday)
        XCTAssertEqual(habit.totalMinutesToday, 30)
    }
    
    func testCurriculumConceptQueueOrdering() throws {
        let habit = Habit(title: "System Design", category: "Architecture", targetMinutes: 45)
        context.insert(habit)
        
        let concept1 = CurriculumConcept(title: "Load Balancers", orderIndex: 0, habit: habit)
        let concept2 = CurriculumConcept(title: "Database Indexing", orderIndex: 1, habit: habit)
        let concept3 = CurriculumConcept(title: "Consistent Hashing", orderIndex: 2, habit: habit)
        
        context.insert(concept1)
        context.insert(concept2)
        context.insert(concept3)
        habit.curriculumQueue.append(contentsOf: [concept1, concept2, concept3])
        
        try context.save()
        
        XCTAssertEqual(habit.uncompletedCurriculum.count, 3)
        XCTAssertEqual(habit.completedCurriculum.count, 0)
        
        // Mark concept1 completed
        concept1.isCompleted = true
        concept1.completedDate = Date()
        try context.save()
        
        XCTAssertEqual(habit.uncompletedCurriculum.count, 2)
        XCTAssertEqual(habit.completedCurriculum.count, 1)
        XCTAssertEqual(habit.completedCurriculum.first?.title, "Load Balancers")
    }
    
    func testCascadeDelete_RemovesSessionsAndConcepts() throws {
        let habit = Habit(title: "Python for DE", category: "Data", targetMinutes: 30)
        context.insert(habit)
        
        let session = HabitSession(durationMinutes: 30, isCompleted: true, habit: habit)
        context.insert(session)
        habit.sessions.append(session)
        
        let concept = CurriculumConcept(title: "PySpark DataFrames", orderIndex: 0, habit: habit)
        context.insert(concept)
        habit.curriculumQueue.append(concept)
        
        try context.save()
        
        // Assert items exist
        XCTAssertEqual(try context.fetch(FetchDescriptor<Habit>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<HabitSession>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<CurriculumConcept>()).count, 1)
        
        // Delete habit
        context.delete(habit)
        try context.save()
        
        // Assert cascade deleted
        XCTAssertEqual(try context.fetch(FetchDescriptor<Habit>()).count, 0)
        XCTAssertEqual(try context.fetch(FetchDescriptor<HabitSession>()).count, 0)
        XCTAssertEqual(try context.fetch(FetchDescriptor<CurriculumConcept>()).count, 0)
    }
}
