import SwiftUI
import SwiftData

public struct SessionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let session: HabitSession
    
    public init(session: HabitSession) {
        self.session = session
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Full Proof Image (if present)
                    if let photoName = session.photoFileName,
                       let image = ImageStorageService.shared.loadProofImage(named: photoName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                            .padding(.horizontal)
                    }
                    
                    // Session Details Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.habit?.category.uppercased() ?? "SESSION")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text(session.habit?.title ?? "Focus Session")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            
                            Spacer()
                            
                            Text("\(session.durationMinutes) min")
                                .font(.system(.headline, design: .monospaced, weight: .semibold))
                                .foregroundColor(AppTheme.buttonForeground)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.buttonBackground)
                                .clipShape(Capsule())
                        }
                        
                        Divider()
                            .background(AppTheme.border)
                        
                        HStack(spacing: 16) {
                            Label(formattedDate(session.date), systemImage: "calendar")
                            Spacer()
                            Label(formattedTime(session.endTime), systemImage: "clock")
                        }
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(18)
                    .bentoCard()
                    .padding(.horizontal)
                    
                    // Concepts Mastered Section (Itemized)
                    if !session.lessonItems.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("CONCEPTS MASTERED (\(session.lessonItems.count))")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Label("Spaced Repetition", systemImage: "clock.arrow.circlepath")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            VStack(spacing: 10) {
                                ForEach(session.lessonItems) { item in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(item.title)
                                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Spacer()
                                            
                                            Text("Stage \(item.reviewStage)")
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundColor(AppTheme.textSecondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AppTheme.background)
                                                .clipShape(Capsule())
                                        }
                                        
                                        if !item.notes.isEmpty {
                                            Text(item.notes)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(AppTheme.textSecondary)
                                                .lineSpacing(2)
                                        }
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "calendar.badge.clock")
                                                .font(.system(size: 10))
                                                .foregroundColor(Color.green)
                                            Text("Next Review: \(formattedDate(item.nextReviewDate))")
                                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        .padding(.top, 2)
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
                        .padding(18)
                        .bentoCard()
                        .padding(.horizontal)
                    } else {
                        // Fallback Single Concept Card
                        let displayNotes = !session.lessonNotes.isEmpty ? session.lessonNotes : session.notes
                        
                        if !displayNotes.isEmpty || !session.lessonTitle.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("STUDY LESSON & INTERVIEW CONCEPT")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Spacer()
                                    
                                    Label("Stage \(session.reviewStage)", systemImage: "clock.arrow.circlepath")
                                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(AppTheme.surface)
                                        .clipShape(Capsule())
                                }
                                
                                if !session.lessonTitle.isEmpty {
                                    Text(session.lessonTitle)
                                        .font(.system(.headline, design: .rounded, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                
                                if !displayNotes.isEmpty {
                                    Text(displayNotes)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .lineSpacing(4)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .bentoCard()
                            .padding(.horizontal)
                        }
                    }
                    
                    // Delete Button
                    Button(role: .destructive, action: deleteSession) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Log Entry")
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
                .padding(.vertical, 16)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Session Proof & Notes")
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
    
    private func deleteSession() {
        if let photoName = session.photoFileName {
            ImageStorageService.shared.deleteProofImage(named: photoName)
        }
        modelContext.delete(session)
        try? modelContext.save()
        dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
