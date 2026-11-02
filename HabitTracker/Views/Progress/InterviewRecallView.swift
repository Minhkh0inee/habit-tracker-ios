import SwiftUI
import SwiftData

public struct InterviewRecallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \LessonItem.nextReviewDate)
    private var allLessons: [LessonItem]
    
    @State private var currentIndex: Int = 0
    @State private var isNotesRevealed: Bool = false
    @State private var filterOnlyDue: Bool = true
    
    public init() {}
    
    private var dueLessons: [LessonItem] {
        let now = Date()
        return allLessons.filter { $0.nextReviewDate <= now && !$0.isMastered }
    }
    
    private var activeList: [LessonItem] {
        filterOnlyDue ? dueLessons : allLessons
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header Segment Filter
                Picker("Review Filter", selection: $filterOnlyDue) {
                    Text("Due Today (\(dueLessons.count))").tag(true)
                    Text("All Concepts (\(allLessons.count))").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if activeList.isEmpty {
                    emptyStateView
                        .padding(.horizontal)
                    Spacer()
                } else if currentIndex < activeList.count {
                    let currentItem = activeList[currentIndex]
                    
                    VStack(spacing: 16) {
                        // Progress Counter
                        HStack {
                            Text("Card \(currentIndex + 1) of \(activeList.count)")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            stageBadge(currentItem.reviewStage)
                        }
                        .padding(.horizontal)
                        
                        // Flashcard
                        flashcardView(item: currentItem)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // Rating Action Controls
                        if isNotesRevealed {
                            ratingButtons(item: currentItem)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isNotesRevealed = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "eye.fill")
                                    Text("Reveal Explanation & Takeaways")
                                }
                                .font(.system(.body, design: .rounded, weight: .semibold))
                            }
                            .primaryButton(fullWidth: true)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 24)
                } else {
                    completedSessionView
                        .padding(.horizontal)
                    Spacer()
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Interview Recall")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Flashcard View
    private func flashcardView(item: LessonItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category & Review Frequency
            HStack {
                Text(item.category.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Text("\(item.reviewCount) Reviews")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            Divider()
                .background(AppTheme.border)
            
            // Concept Title
            Text(item.title)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Prompt: Explain the core mechanics, complexity tradeoffs, and edge cases out loud.")
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
                .italic()
            
            // Revealed Notes
            if isNotesRevealed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("YOUR NOTES & TAKEAWAYS:")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    ScrollView {
                        Text(item.notes.isEmpty ? "No notes recorded during session." : item.notes)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 180)
                }
                .padding(14)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 340)
        .bentoCard()
    }
    
    // MARK: - Rating Buttons
    private func ratingButtons(item: LessonItem) -> some View {
        HStack(spacing: 12) {
            Button(action: { rateItem(item, nailed: false) }) {
                VStack(spacing: 4) {
                    Text("❌ Hard / Forgot")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(.red)
                    Text("Reset to Stage 1")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            Button(action: { rateItem(item, nailed: true) }) {
                VStack(spacing: 4) {
                    Text("✅ Nailed It!")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(AppTheme.buttonForeground)
                    Text("Advance Interval")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(AppTheme.buttonForeground.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    private func rateItem(_ item: LessonItem, nailed: Bool) {
        let generator = UINotificationFeedbackGenerator()
        if nailed {
            item.advanceReviewStage()
            generator.notificationOccurred(.success)
        } else {
            item.resetReviewStage()
            generator.notificationOccurred(.warning)
        }
        
        try? modelContext.save()
        
        withAnimation(.easeInOut(duration: 0.25)) {
            isNotesRevealed = false
            currentIndex += 1
        }
    }
    
    // MARK: - Stage Badge
    private func stageBadge(_ stage: Int) -> some View {
        let label = stage >= 5 ? "Stage 5 (Mastered)" : "Stage \(stage)/5"
        return Text(label)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(AppTheme.surface)
            .foregroundColor(stage >= 5 ? .green : AppTheme.textPrimary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(AppTheme.border, lineWidth: 1)
            )
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("No Reviews Due Right Now! 🎉")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Your spaced repetition Leitner intervals are up to date. You can switch to 'All Concepts' to practice ahead, or complete study timer sessions to queue new topics.")
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .bentoCard()
    }
    
    // MARK: - Completed Session View
    private var completedSessionView: some View {
        VStack(spacing: 14) {
            Image(systemName: "star.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            Text("Recall Round Finished!")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Great job keeping your engineering concepts fresh for upcoming technical interviews.")
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Done") {
                dismiss()
            }
            .primaryButton(fullWidth: false)
            .padding(.top, 8)
        }
        .padding(28)
        .bentoCard()
    }
}
