import SwiftUI
import SwiftData

public struct HabitCurriculumSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable public var habit: Habit
    public let onStartTimerWithConcept: ((Habit, CurriculumConcept) -> Void)?
    
    @State private var showingAddConceptSheet: Bool = false
    @State private var showingAIGeneratorSheet: Bool = false
    @State private var selectedConceptForDetail: CurriculumConcept?
    
    // Add concept form state
    @State private var newConceptTitle: String = ""
    @State private var newConceptDescription: String = ""
    @State private var newConceptMinutes: Int = 25
    
    // AI Generator form state
    @State private var aiCustomTopic: String = ""
    @State private var aiApiKey: String = GeminiSyncService.shared.storedApiKey
    @State private var isGeneratingAI: Bool = false
    @State private var aiErrorMessage: String?
    
    public init(
        habit: Habit,
        onStartTimerWithConcept: ((Habit, CurriculumConcept) -> Void)? = nil
    ) {
        self.habit = habit
        self.onStartTimerWithConcept = onStartTimerWithConcept
    }
    
    private var totalConceptsCount: Int {
        habit.curriculumQueue.count
    }
    
    private var completedCount: Int {
        habit.completedCurriculum.count
    }
    
    private var progressRatio: Double {
        guard totalConceptsCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalConceptsCount)
    }
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Overview Card
                        curriculumProgressCard
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Action Buttons: Add Custom or AI Generate
                        actionsBar
                            .padding(.horizontal)
                        
                        // SECTION 1: Today's Scheduled Concepts
                        todayScheduledSection
                            .padding(.horizontal)
                        
                        // SECTION 2: Upcoming Roadmap Backlog
                        upcomingBacklogSection
                            .padding(.horizontal)
                        
                        // SECTION 3: Completed / Mastered Concepts
                        if !habit.completedCurriculum.isEmpty {
                            completedConceptsSection
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .scrollBounceBehavior(.basedOnSize)
                .background(AppTheme.background.ignoresSafeArea())
                .navigationTitle("\(habit.title) Syllabus")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .sheet(isPresented: $showingAddConceptSheet) {
                    addCustomConceptSheet
                }
                .sheet(isPresented: $showingAIGeneratorSheet) {
                    aiGeneratorSheet
                }
            }
        }
    }
    
    // MARK: - Progress Overview Card
    private var curriculumProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ROADMAP PROGRESS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("\(completedCount) of \(totalConceptsCount) Concepts Mastered")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                Text("\(Int(progressRatio * 100))%")
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            // Progress Bar
            MinimalProgressBar(progress: progressRatio, height: 8)
        }
        .padding(16)
        .bentoCard()
    }
    
    // MARK: - Actions Bar
    private var actionsBar: some View {
        HStack(spacing: 10) {
            Button(action: { showingAddConceptSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Add Concept")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppTheme.surface)
                .foregroundColor(AppTheme.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            Button(action: { showingAIGeneratorSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                    Text("AI Generate (Gemini)")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppTheme.textPrimary)
                .foregroundColor(AppTheme.buttonForeground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - SECTION 1: Today's Scheduled Concepts
    private var todayScheduledSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🎯 Today's Goal (~\(habit.todayScheduledMinutes)m)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(habit.todayScheduledConcepts.count) Planned")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if habit.todayScheduledConcepts.isEmpty {
                VStack(spacing: 8) {
                    Text("All Caught Up! 🎉")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("You've mastered all concepts in this queue or haven't added any yet.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .bentoCard()
            } else {
                ForEach(habit.todayScheduledConcepts) { concept in
                    conceptRowView(concept: concept, isTodayQueue: true)
                }
            }
        }
    }
    
    // MARK: - SECTION 2: Upcoming Backlog
    private var upcomingBacklogSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Upcoming Queue (\(habit.uncompletedCurriculum.count))")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
            }
            
            let backlog = habit.uncompletedCurriculum
            if backlog.isEmpty {
                Text("No upcoming concepts in backlog.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(backlog) { concept in
                    if !habit.todayScheduledConcepts.contains(where: { $0.id == concept.id }) {
                        conceptRowView(concept: concept, isTodayQueue: false)
                    }
                }
            }
        }
    }
    
    // MARK: - SECTION 3: Completed Concepts
    private var completedConceptsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Completed & Mastered (\(completedCount))")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
            }
            
            ForEach(habit.completedCurriculum) { concept in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.textPrimary)
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(concept.title)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .strikethrough()
                        
                        if let date = concept.completedDate {
                            Text("Completed on \(AppFormatters.mediumDate(date))")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { toggleComplete(concept) }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .bentoCard()
            }
        }
    }
    
    // MARK: - Concept Row View
    private func conceptRowView(concept: CurriculumConcept, isTodayQueue: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Button(action: { toggleComplete(concept) }) {
                    Image(systemName: concept.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(concept.isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if concept.isRolledOver {
                            Text("ROLLED OVER")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.18))
                                .foregroundColor(.orange)
                                .clipShape(Capsule())
                        }
                        
                        Text("\(concept.estimatedMinutes)m")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.surface)
                            .foregroundColor(AppTheme.textSecondary)
                            .clipShape(Capsule())
                        
                        if concept.isAISynced {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    Text(concept.title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if !concept.conceptDescription.isEmpty {
                        Text(concept.conceptDescription)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if isTodayQueue && onStartTimerWithConcept != nil {
                    Button(action: {
                        onStartTimerWithConcept?(habit, concept)
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 11))
                            Text("Timer")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.textPrimary)
                        .foregroundColor(AppTheme.buttonForeground)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .bentoCard()
        .contextMenu {
            Button(role: .destructive) {
                deleteConcept(concept)
            } label: {
                Label("Delete Concept", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Toggle Complete
    private func toggleComplete(_ concept: CurriculumConcept) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            concept.isCompleted.toggle()
            if concept.isCompleted {
                concept.completedDate = Date()
                
                let targetTitle = concept.title
                let existingDescriptor = FetchDescriptor<LessonItem>(
                    predicate: #Predicate<LessonItem> { item in
                        item.title == targetTitle
                    }
                )
                let existing = (try? modelContext.fetch(existingDescriptor)) ?? []
                if existing.isEmpty {
                    let lessonItem = LessonItem(
                        title: concept.title,
                        notes: concept.conceptDescription,
                        category: habit.category,
                        habit: habit
                    )
                    modelContext.insert(lessonItem)
                }
            } else {
                concept.completedDate = nil
            }
            try? modelContext.save()
        }
    }
    
    private func deleteConcept(_ concept: CurriculumConcept) {
        withAnimation {
            if let idx = habit.curriculumQueue.firstIndex(where: { $0.id == concept.id }) {
                habit.curriculumQueue.remove(at: idx)
            }
            modelContext.delete(concept)
            try? modelContext.save()
        }
    }
    
    // MARK: - Add Custom Concept Modal
    private var addCustomConceptSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Concept Details").foregroundColor(AppTheme.textSecondary)) {
                    TextField("Concept Title (e.g. Memory Layout)", text: $newConceptTitle)
                        .font(.system(.body, design: .rounded))
                    
                    TextField("Short Notes / Objectives (Optional)", text: $newConceptDescription, axis: .vertical)
                        .lineLimit(3...5)
                        .font(.system(.body, design: .rounded))
                }
                
                Section(header: Text("Estimated Study Time").foregroundColor(AppTheme.textSecondary)) {
                    Stepper("\(newConceptMinutes) Minutes", value: $newConceptMinutes, in: 10...180, step: 5)
                        .font(.system(.body, design: .rounded))
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("New Concept")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAddConceptSheet = false }
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Queue") {
                        addCustomConcept()
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .disabled(newConceptTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func addCustomConcept() {
        let trimmedTitle = newConceptTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newConcept = CurriculumConcept(
            title: trimmedTitle,
            conceptDescription: newConceptDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            category: habit.category,
            estimatedMinutes: newConceptMinutes,
            orderIndex: habit.curriculumQueue.count,
            habit: habit
        )
        
        modelContext.insert(newConcept)
        habit.curriculumQueue.append(newConcept)
        try? modelContext.save()
        
        newConceptTitle = ""
        newConceptDescription = ""
        newConceptMinutes = 25
        showingAddConceptSheet = false
    }
    
    // MARK: - AI Generator Modal
    private var aiGeneratorSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Gemini AI Roadmap Generator").foregroundColor(AppTheme.textSecondary)) {
                    Text("Gemini will generate 6 to 8 tailored study concepts with time estimates based on real-world engineering interviews.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    TextField("Specific Topic Focus (e.g., Concurrency, PySpark)", text: $aiCustomTopic)
                        .font(.system(.body, design: .rounded))
                }
                
                Section(header: Text("Gemini API Key").foregroundColor(AppTheme.textSecondary)) {
                    SecureField("Paste Gemini API Key", text: $aiApiKey)
                        .font(.system(.subheadline, design: .monospaced))
                }
                
                if let error = aiErrorMessage {
                    Section {
                        Text(error)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: generateWithAI) {
                        HStack {
                            Spacer()
                            if isGeneratingAI {
                                ProgressView()
                                    .tint(AppTheme.buttonForeground)
                                    .padding(.trailing, 6)
                                Text("Generating Roadmap...")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            } else {
                                Image(systemName: "sparkles")
                                Text("Generate Concepts")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            }
                            Spacer()
                        }
                    }
                    .primaryButton(fullWidth: true)
                    .disabled(isGeneratingAI || aiApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("AI Syllabus Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAIGeneratorSheet = false }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func generateWithAI() {
        let cleanKey = aiApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKey.isEmpty else { return }
        
        GeminiSyncService.shared.storedApiKey = cleanKey
        isGeneratingAI = true
        aiErrorMessage = nil
        
        Task {
            do {
                let dtos = try await GeminiSyncService.shared.generateCurriculum(
                    track: habit.title,
                    customTopic: aiCustomTopic.isEmpty ? nil : aiCustomTopic,
                    targetMinutes: habit.targetMinutes,
                    apiKey: cleanKey
                )
                
                await MainActor.run {
                    var startIndex = habit.curriculumQueue.count
                    for dto in dtos {
                        let concept = CurriculumConcept(
                            title: dto.title,
                            conceptDescription: dto.description,
                            category: habit.category,
                            estimatedMinutes: dto.estimatedMinutes,
                            orderIndex: startIndex,
                            isCompleted: false,
                            isAISynced: true,
                            habit: habit
                        )
                        modelContext.insert(concept)
                        habit.curriculumQueue.append(concept)
                        startIndex += 1
                    }
                    
                    try? modelContext.save()
                    isGeneratingAI = false
                    showingAIGeneratorSheet = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingAI = false
                    aiErrorMessage = error.localizedDescription
                }
            }
        }
    }
}
