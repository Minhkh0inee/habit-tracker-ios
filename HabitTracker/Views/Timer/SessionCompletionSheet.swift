import SwiftUI
import SwiftData
import PhotosUI

public struct SessionCompletionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let habit: Habit?
    public let durationMinutes: Int
    public let onSaved: () -> Void
    
    // Struct for itemized learning inputs
    public struct ConceptInputItem: Identifiable {
        public let id = UUID()
        public var title: String = ""
        public var notes: String = ""
        
        public init(title: String = "", notes: String = "") {
            self.title = title
            self.notes = notes
        }
    }
    
    @State private var conceptItems: [ConceptInputItem] = [ConceptInputItem()]
    @State private var capturedImage: UIImage?
    @State private var showingCamera: Bool = false
    @State private var showingPhotoPicker: Bool = false
    @State private var isSaving: Bool = false
    
    @Query(sort: \InterviewQuestion.createdAt, order: .reverse)
    private var aiQuestions: [InterviewQuestion]
    
    public init(
        habit: Habit?,
        durationMinutes: Int,
        onSaved: @escaping () -> Void = {}
    ) {
        self.habit = habit
        self.durationMinutes = max(1, durationMinutes)
        self.onSaved = onSaved
    }
    
    private var curatedSuggestions: [EngineeringConcept] {
        guard let habit = habit else { return [] }
        return Array(EngineeringConceptBank.concepts(for: habit.category).prefix(4))
    }
    
    private var matchingAIQuestions: [InterviewQuestion] {
        guard let habit = habit else { return [] }
        return aiQuestions.filter {
            $0.category.localizedCaseInsensitiveContains(habit.category) ||
            habit.category.localizedCaseInsensitiveContains($0.category)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    conceptsSection
                    photoProofSection
                    submitButtonsSection
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Log Learning Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(image: $capturedImage)
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoLibraryPickerView(image: $capturedImage)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 38))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.top, 4)
            
            Text("Session Complete")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if let habit = habit {
                Text("\(habit.title) • \(durationMinutes)m focus logged")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                Text("\(durationMinutes)m focus session logged")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }
    
    // MARK: - Concepts Learned Section
    private var conceptsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CONCEPTS LEARNED")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("What did you master today?")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                Text("\(conceptItems.count) Item\(conceptItems.count > 1 ? "s" : "")")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.surface)
                    .clipShape(Capsule())
            }
            
            suggestedPillsSection
            
            // Dynamic List of Concept Input Cards
            VStack(spacing: 12) {
                ForEach(Array(conceptItems.enumerated()), id: \.element.id) { index, item in
                    conceptItemCard(index: index)
                }
            }
            
            // "+ Add Another Concept" Button
            Button(action: addAnotherConcept) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 15))
                    Text("Add Another Concept")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.border, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .bentoCard()
        .padding(.horizontal)
    }
    
    // MARK: - Suggested Quick-Fill Pills
    @ViewBuilder
    private var suggestedPillsSection: some View {
        let scheduledConcepts = habit?.todayScheduledConcepts ?? []
        let hasContent = !scheduledConcepts.isEmpty || !matchingAIQuestions.isEmpty || !curatedSuggestions.isEmpty
        
        if hasContent {
            VStack(alignment: .leading, spacing: 6) {
                Text("Suggested Topics & Real Interview Questions:")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(scheduledConcepts, id: \.id) { concept in
                            curriculumGoalPill(title: concept.title, notes: concept.conceptDescription)
                        }
                        
                        ForEach(matchingAIQuestions, id: \.id) { q in
                            aiQuestionPill(question: q)
                        }
                        
                        ForEach(curatedSuggestions, id: \.id) { concept in
                            curatedConceptPill(concept: concept)
                        }
                    }
                }
            }
        }
    }
    
    private func curriculumGoalPill(title: String, notes: String) -> some View {
        Button(action: { fillConcept(title: title, notes: notes) }) {
            HStack(spacing: 4) {
                Image(systemName: "target")
                    .font(.system(size: 9))
                Text("Goal: \(title)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundColor(AppTheme.buttonForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.textPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private func aiQuestionPill(question: InterviewQuestion) -> some View {
        Button(action: { fillAIQuestion(question) }) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 9))
                    .foregroundColor(Color.green)
                Text("\(question.companyTag): \(question.title)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func curatedConceptPill(concept: EngineeringConcept) -> some View {
        Button(action: { fillSuggestedConcept(concept) }) {
            HStack(spacing: 4) {
                Image(systemName: "book.closed")
                    .font(.system(size: 9))
                Text(concept.title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Photo Proof Section
    private var photoProofSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photo Proof of Work")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(capturedImage != nil ? "Captured" : "Optional")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.surface)
                    .clipShape(Capsule())
            }
            
            if let image = capturedImage {
                capturedImagePreview(image)
            } else {
                photoActionButtons
            }
        }
        .padding(16)
        .bentoCard()
        .padding(.horizontal)
    }
    
    private func capturedImagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 10) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            
            HStack(spacing: 10) {
                Button(action: openCameraOrPicker) {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                        Text("Retake")
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                
                Button(action: { showingPhotoPicker = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle")
                        Text("Gallery")
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }
    
    private var photoActionButtons: some View {
        HStack(spacing: 12) {
            Button(action: openCameraOrPicker) {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                    Text("Snap Photo")
                }
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            Button(action: { showingPhotoPicker = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "photo")
                    Text("Pick Library")
                }
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Submit Buttons
    private var submitButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: saveSession) {
                if isSaving {
                    ProgressView()
                        .tint(AppTheme.buttonForeground)
                } else {
                    Text("Submit & Save \(validItemCount > 0 ? "\(validItemCount) Concept(s)" : "Session")")
                }
            }
            .primaryButton()
            .disabled(isSaving)
            
            Button("Discard Session") {
                dismiss()
            }
            .font(.system(.subheadline, design: .rounded))
            .foregroundColor(AppTheme.textSecondary)
            .padding(.top, 4)
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 24)
    }
    
    // MARK: - Single Concept Input Card
    private func conceptItemCard(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Concept #\(index + 1)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                if conceptItems.count > 1 {
                    Button(action: { removeConceptItem(at: index) }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            TextField("Concept title (e.g. Binary Search invariant)", text: $conceptItems[index].title)
                .font(.system(.body, design: .rounded))
                .padding(10)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            
            TextField("Key takeaway, formula, tradeoff, or edge cases...", text: $conceptItems[index].notes, axis: .vertical)
                .font(.system(.subheadline, design: .rounded))
                .lineLimit(2...4)
                .padding(10)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
    
    // MARK: - Actions
    private var validItemCount: Int {
        conceptItems.filter {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.count
    }
    
    private func addAnotherConcept() {
        withAnimation(.easeInOut(duration: 0.2)) {
            conceptItems.append(ConceptInputItem())
        }
    }
    
    private func removeConceptItem(at index: Int) {
        guard conceptItems.count > 1, index < conceptItems.count else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            _ = conceptItems.remove(at: index)
        }
    }
    
    private func fillConcept(title: String, notes: String) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if let lastIndex = conceptItems.indices.last,
           conceptItems[lastIndex].title.isEmpty && conceptItems[lastIndex].notes.isEmpty {
            conceptItems[lastIndex].title = cleanTitle
            conceptItems[lastIndex].notes = cleanNotes
        } else {
            conceptItems.append(ConceptInputItem(title: cleanTitle, notes: cleanNotes))
        }
    }
    
    private func fillSuggestedConcept(_ concept: EngineeringConcept) {
        fillConcept(title: concept.title, notes: concept.summary)
    }
    
    private func fillScheduledConcept(_ concept: CurriculumConcept) {
        fillConcept(title: concept.title, notes: concept.conceptDescription)
    }
    
    private func fillAIQuestion(_ question: InterviewQuestion) {
        let noteText = "\(question.question)\n\nKey Takeaways:\n\(question.keyTakeaways)"
        fillConcept(title: question.title, notes: noteText)
    }
    
    private func openCameraOrPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showingCamera = true
        } else {
            showingPhotoPicker = true
        }
    }
    
    private func saveSession() {
        isSaving = true
        
        var photoFileName: String? = nil
        if let image = capturedImage {
            photoFileName = ImageStorageService.shared.saveProofImage(image)
        }
        
        // Filter out empty items
        let validItems = conceptItems.filter {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        let firstTitle = validItems.first?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? (habit?.title ?? "Study Session")
        let firstNotes = validItems.first?.notes.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let session = HabitSession(
            startTime: Date().addingTimeInterval(-Double(durationMinutes * 60)),
            endTime: Date(),
            durationMinutes: durationMinutes,
            isCompleted: true,
            photoFileName: photoFileName,
            notes: firstNotes.isEmpty ? firstTitle : firstNotes,
            lessonTitle: firstTitle,
            lessonNotes: firstNotes,
            reviewStage: 0,
            nextReviewDate: HabitSession.calculateNextReviewDate(from: 0),
            reviewCount: 0,
            isMastered: false,
            date: Date(),
            habit: habit
        )
        
        modelContext.insert(session)
        
        // Create each individual LessonItem for Spaced Repetition tracking
        for item in validItems {
            let cleanTitle = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanNotes = item.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanTitle.isEmpty || !cleanNotes.isEmpty else { continue }
            
            let lessonItem = LessonItem(
                title: cleanTitle.isEmpty ? "Learned Concept" : cleanTitle,
                notes: cleanNotes,
                category: habit?.category ?? "General",
                createdAt: Date(),
                reviewStage: 0,
                nextReviewDate: HabitSession.calculateNextReviewDate(from: 0),
                reviewCount: 0,
                isMastered: false,
                session: session,
                habit: habit
            )
            modelContext.insert(lessonItem)
            session.lessonItems.append(lessonItem)
        }
        
        if let habit = habit {
            habit.sessions.append(session)
            
            // Mark any matching curriculum concepts as completed
            for item in validItems {
                let cleanTitle = item.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                for concept in habit.uncompletedCurriculum {
                    if concept.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == cleanTitle {
                        concept.isCompleted = true
                        concept.completedDate = Date()
                    }
                }
            }
        }
        
        try? modelContext.save()
        
        NotificationManager.shared.cancelAtRiskNotification()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        onSaved()
        dismiss()
    }
}
