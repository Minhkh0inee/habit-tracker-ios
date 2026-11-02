import SwiftUI
import SwiftData

public struct EditHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable public var habit: Habit
    
    @State private var title: String
    @State private var category: String
    @State private var targetMinutes: Int
    @State private var iconName: String
    
    @State private var showDeleteConfirmation: Bool = false
    
    public let onDeleted: (() -> Void)?
    
    private let presetDurations = [15, 25, 30, 45, 60, 90]
    
    private let availableIcons = [
        "swift",
        "point.3.connected.trianglepath.dotted",
        "network",
        "cylinder.split.1x2",
        "terminal",
        "chevron.left.forwardslash.chevron.right",
        "cpu",
        "server.rack",
        "brain",
        "book.closed",
        "chart.bar.xaxis",
        "wrench.and.screwdriver",
        "checklist",
        "flame",
        "bolt",
        "target"
    ]
    
    public init(habit: Habit, onDeleted: (() -> Void)? = nil) {
        self.habit = habit
        self.onDeleted = onDeleted
        _title = State(initialValue: habit.title)
        _category = State(initialValue: habit.category)
        _targetMinutes = State(initialValue: habit.targetMinutes)
        _iconName = State(initialValue: habit.iconName)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - Habit Details
                Section(header: Text("Habit Info").foregroundColor(AppTheme.textSecondary)) {
                    TextField("Habit Title (e.g. Swift Concurrency)", text: $title)
                        .font(.system(.body, design: .rounded))
                    
                    TextField("Category (e.g. Mobile, DSA)", text: $category)
                        .font(.system(.body, design: .rounded))
                }
                
                // MARK: - Target Focus Duration
                Section(header: Text("Daily Target Focus Time").foregroundColor(AppTheme.textSecondary)) {
                    HStack(spacing: 8) {
                        ForEach(presetDurations, id: \.self) { mins in
                            Button(action: { targetMinutes = mins }) {
                                Text("\(mins)m")
                                    .font(.system(.caption, design: .monospaced, weight: targetMinutes == mins ? .bold : .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(targetMinutes == mins ? AppTheme.textPrimary : AppTheme.surface)
                                    .foregroundColor(targetMinutes == mins ? AppTheme.buttonForeground : AppTheme.textPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(AppTheme.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Stepper("Custom: \(targetMinutes) minutes", value: $targetMinutes, in: 5...300, step: 5)
                        .font(.system(.body, design: .rounded))
                }
                
                // MARK: - Icon Selector
                Section(header: Text("Habit Icon").foregroundColor(AppTheme.textSecondary)) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: { iconName = icon }) {
                                Image(systemName: icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(iconName == icon ? AppTheme.buttonForeground : AppTheme.textPrimary)
                                    .frame(width: 42, height: 42)
                                    .background(iconName == icon ? AppTheme.textPrimary : AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(AppTheme.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Danger Zone: Delete Habit
                Section {
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        HStack {
                            Spacer()
                            Label("Delete Habit & History", systemImage: "trash.fill")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Habit?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteHabit()
                }
            } message: {
                Text("Are you sure you want to delete '\(habit.title)'? This will permanently remove this habit, its curriculum queue, and all logged study sessions and photos.")
            }
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else { return }
        
        habit.title = trimmedTitle
        habit.category = trimmedCategory.isEmpty ? "General" : trimmedCategory
        habit.targetMinutes = targetMinutes
        habit.iconName = iconName
        
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteHabit() {
        // Delete photo proofs associated with sessions
        for session in habit.sessions {
            if let photoName = session.photoFileName {
                ImageStorageService.shared.deleteProofImage(named: photoName)
            }
        }
        
        // Delete habit
        modelContext.delete(habit)
        try? modelContext.save()
        
        onDeleted?()
        dismiss()
    }
}
