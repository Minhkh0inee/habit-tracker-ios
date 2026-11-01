import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Habit.self,
                HabitSession.self,
                LessonItem.self,
                InterviewQuestion.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Clean any leftover test sessions from November 1st
            cleanTestDataIfNeeded(context: container.mainContext)
            
            // Seed clean default habits if database is completely empty
            seedInitialHabitsIfNeeded(context: container.mainContext)
            
            // Request notification permissions & schedule daily 5:00 AM reminder
            NotificationManager.shared.requestAuthorization()
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error)")
        }
    }
    
    @State private var showSplash: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(container)
    }
    
    /// Wipes all test session records and test proof images to ensure a fresh, clean slate
    private func cleanTestDataIfNeeded(context: ModelContext) {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasCleanedTestData_v1") {
            do {
                let sessionDescriptor = FetchDescriptor<HabitSession>()
                let allSessions = try context.fetch(sessionDescriptor)
                for session in allSessions {
                    if let photoName = session.photoFileName {
                        ImageStorageService.shared.deleteProofImage(named: photoName)
                    }
                    context.delete(session)
                }
                
                // Clear any sessions from habit relationship arrays
                let habitDescriptor = FetchDescriptor<Habit>()
                let allHabits = try context.fetch(habitDescriptor)
                for habit in allHabits {
                    habit.sessions.removeAll()
                }
                
                try context.save()
                defaults.set(true, forKey: "hasCleanedTestData_v1")
                print("All test data from November 1st cleared successfully.")
            } catch {
                print("Error clearing test sessions: \(error)")
            }
        }
    }
    
    /// Seeds the initial clean template habits if none exist (with 0 completed sessions)
    private func seedInitialHabitsIfNeeded(context: ModelContext) {
        var fetchDescriptor = FetchDescriptor<Habit>()
        fetchDescriptor.fetchLimit = 1
        
        do {
            let existing = try context.fetch(fetchDescriptor)
            if existing.isEmpty {
                for habit in Habit.defaultTechHabits {
                    context.insert(habit)
                }
                try context.save()
            }
        } catch {
            print("Failed to seed default habits: \(error)")
        }
    }
}
