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
                InterviewQuestion.self,
                CurriculumConcept.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Seed clean default habits if database is completely empty
            seedInitialHabitsIfNeeded(context: container.mainContext)
            
            // Seed curated learning roadmaps for habits that don't have concepts yet
            seedCurriculaForHabitsIfNeeded(context: container.mainContext)
            
            // Request notification permissions & schedule daily 5:00 AM reminder
            NotificationManager.shared.requestAuthorization()
            
            // Sync initial widget streak snapshot
            if let habits = try? container.mainContext.fetch(FetchDescriptor<Habit>()) {
                StreakWidgetSnapshotService.shared.saveSnapshot(from: habits)
            }
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error)")
        }
    }
    
    @Environment(\.scenePhase) private var scenePhase
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
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active || newPhase == .background {
                    if let habits = try? container.mainContext.fetch(FetchDescriptor<Habit>()) {
                        StreakWidgetSnapshotService.shared.saveSnapshot(from: habits)
                    }
                }
            }
        }
        .modelContainer(container)
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
    
    /// Pre-seeds rich curated curriculum tracks for habits if their syllabus queue is empty
    private func seedCurriculaForHabitsIfNeeded(context: ModelContext) {
        do {
            let habitDescriptor = FetchDescriptor<Habit>()
            let allHabits = try context.fetch(habitDescriptor)
            
            var didAddAny = false
            for habit in allHabits {
                let isPythonHabit = habit.title.lowercased().contains("python")
                let hasWrongDECurriculum = isPythonHabit && habit.curriculumQueue.contains(where: {
                    $0.title.contains("Data Warehouses") || $0.title.contains("Lakehouses") || $0.title.contains("Star vs Snowflake")
                })
                
                // Auto-correct: If Python habit received Data Engineering concepts due to substring match, replace with Python language concepts
                if hasWrongDECurriculum {
                    for oldConcept in habit.curriculumQueue {
                        context.delete(oldConcept)
                    }
                    habit.curriculumQueue.removeAll()
                }
                
                // Auto-update: If System Design habit has the legacy curriculum, upgrade it to the System-Design-Primer roadmap
                let isSystemDesignHabit = habit.title.lowercased().contains("system design")
                let hasLegacySDCurriculum = isSystemDesignHabit && habit.curriculumQueue.contains(where: {
                    $0.title.contains("Distributed Transactions: 2-Phase Commit") || $0.title.contains("DynamoDB Style")
                })
                if hasLegacySDCurriculum {
                    for oldConcept in habit.curriculumQueue {
                        context.delete(oldConcept)
                    }
                    habit.curriculumQueue.removeAll()
                }
                
                if habit.curriculumQueue.isEmpty {
                    let seedList = CurriculumSeedData.defaultConcepts(for: habit.title)
                    for (index, seed) in seedList.enumerated() {
                        let concept = CurriculumConcept(
                            title: seed.title,
                            conceptDescription: seed.description,
                            category: habit.category,
                            estimatedMinutes: seed.estimatedMinutes,
                            orderIndex: index,
                            isCompleted: false,
                            habit: habit
                        )
                        context.insert(concept)
                        habit.curriculumQueue.append(concept)
                        didAddAny = true
                    }
                }
            }
            
            if didAddAny {
                try context.save()
                print("Curated curricula seeded successfully.")
            }
        } catch {
            print("Failed to seed curricula: \(error)")
        }
    }
}
