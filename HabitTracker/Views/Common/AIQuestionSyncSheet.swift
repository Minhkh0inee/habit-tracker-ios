import SwiftUI
import SwiftData

public struct AIQuestionSyncSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Checkbox Track Items
    public struct TrackOption: Identifiable {
        public let id = UUID()
        public let name: String
        public let categoryTag: String
        public let icon: String
        public var isSelected: Bool
    }
    
    @State private var tracks: [TrackOption] = [
        TrackOption(name: "Swift & iOS Development", categoryTag: "Mobile", icon: "swift", isSelected: true),
        TrackOption(name: "Data Structures & Algorithms", categoryTag: "Computer Science", icon: "point.3.connected.trianglepath.dotted", isSelected: true),
        TrackOption(name: "System Design & Architecture", categoryTag: "Architecture", icon: "network", isSelected: false),
        TrackOption(name: "Data Engineering (DE)", categoryTag: "Data", icon: "cylinder.split.1x2", isSelected: false),
        TrackOption(name: "Python for DE & Tools", categoryTag: "Languages & Tools", icon: "terminal", isSelected: false)
    ]
    
    @State private var apiKey: String = GeminiSyncService.shared.storedApiKey
    @State private var isSyncing: Bool = false
    @State private var errorMessage: String? = nil
    @State private var syncedCount: Int = 0
    @State private var syncedQuestionsPreview: [GeminiSyncService.AISyncedQuestionDTO] = []
    
    public init() {}
    
    private var selectedCategories: [String] {
        tracks.filter { $0.isSelected }.map { $0.categoryTag }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("AI Question Bank Sync")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Text("Select the engineering tracks you want to pull. Gemini AI will fetch recent real-world interview questions and concept challenges asked by top tech companies.")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(16)
                    .bentoCard()
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // API Key Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GEMINI API TOKEN")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        SecureField("Paste your Gemini API Token here", text: $apiKey)
                            .font(.system(.subheadline, design: .monospaced))
                            .padding(12)
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        
                        Text("Uses Gemini 2.5 Flash for high-yield, structured technical interview questions.")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding(.horizontal)
                    
                    // Checkbox Selection Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SELECT TRACKS TO PULL")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach($tracks) { $track in
                                Button(action: {
                                    track.isSelected.toggle()
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: track.isSelected ? "checkmark.square.fill" : "square")
                                            .font(.system(size: 18))
                                            .foregroundColor(track.isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                                        
                                        Image(systemName: track.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(AppTheme.textPrimary)
                                            .frame(width: 28, height: 28)
                                        
                                        Text(track.name)
                                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Spacer()
                                    }
                                    .padding(12)
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
                        .padding(.horizontal)
                    }
                    
                    // Error message if any
                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Sync Action Button
                    Button(action: startSync) {
                        if isSyncing {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(AppTheme.buttonForeground)
                                Text("Fetching Real-World Interview Questions...")
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sync Selected Tracks with Gemini")
                            }
                        }
                    }
                    .primaryButton()
                    .disabled(isSyncing || selectedCategories.isEmpty || apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(isSyncing || selectedCategories.isEmpty || apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    .padding(.horizontal)
                    
                    // Preview of Synced Questions (if available)
                    if !syncedQuestionsPreview.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("SYNCED QUESTIONS (\(syncedCount))")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textSecondary)
                                Spacer()
                                Text("Saved to Question Bank")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.green)
                            }
                            
                            VStack(spacing: 10) {
                                ForEach(syncedQuestionsPreview, id: \.title) { q in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(q.title)
                                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Spacer()
                                            Text(q.companyTag)
                                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                                .foregroundColor(AppTheme.buttonForeground)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AppTheme.buttonBackground)
                                                .clipShape(Capsule())
                                        }
                                        
                                        Text(q.question)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text(q.keyTakeaways)
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(AppTheme.textSecondary)
                                            .lineLimit(3)
                                    }
                                    .padding(12)
                                    .background(AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(AppTheme.border, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(16)
                        .bentoCard()
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("AI Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Sync Action
    private func startSync() {
        isSyncing = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedQuestions = try await GeminiSyncService.shared.fetchLatestInterviewQuestions(
                    categories: selectedCategories,
                    apiKey: apiKey
                )
                
                // Insert each question into SwiftData
                await MainActor.run {
                    for q in fetchedQuestions {
                        let newQuestion = InterviewQuestion(
                            category: q.category,
                            title: q.title,
                            question: q.question,
                            keyTakeaways: q.keyTakeaways,
                            companyTag: q.companyTag,
                            difficulty: q.difficulty,
                            isAISynced: true,
                            createdAt: Date(),
                            reviewStage: 0,
                            nextReviewDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                            reviewCount: 0,
                            isMastered: false
                        )
                        modelContext.insert(newQuestion)
                    }
                    
                    try? modelContext.save()
                    
                    self.syncedQuestionsPreview = fetchedQuestions
                    self.syncedCount = fetchedQuestions.count
                    self.isSyncing = false
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSyncing = false
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
}
