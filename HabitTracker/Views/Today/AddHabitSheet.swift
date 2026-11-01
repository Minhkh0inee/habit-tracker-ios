import SwiftUI
import SwiftData

public struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var category: String = "Engineering"
    @State private var targetMinutes: Int = 30
    @State private var selectedIcon: String = "terminal"
    
    private let availableIcons = [
        "terminal",
        "swift",
        "point.3.connected.trianglepath.dotted",
        "network",
        "cylinder.split.1x2",
        "chevron.left.forwardslash.chevron.right",
        "cpu",
        "curlybraces",
        "book.closed",
        "laptopcomputer",
        "server.rack",
        "externaldrive.connected.to.line.below"
    ]
    
    private let durationOptions = [15, 20, 30, 45, 60, 90]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Habit Details").foregroundColor(AppTheme.textSecondary)) {
                    TextField("Habit Title (e.g. Docker & Kubernetes)", text: $title)
                    TextField("Category (e.g. DevOps, Backend)", text: $category)
                }
                
                Section(header: Text("Daily Target").foregroundColor(AppTheme.textSecondary)) {
                    Picker("Target Minutes", selection: $targetMinutes) {
                        ForEach(durationOptions, id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                }
                
                Section(header: Text("Choose Icon").foregroundColor(AppTheme.textSecondary)) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            let isSelected = selectedIcon == icon
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(isSelected ? AppTheme.buttonForeground : AppTheme.textPrimary)
                                    .frame(width: 44, height: 44)
                                    .background(isSelected ? AppTheme.buttonBackground : AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(AppTheme.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createHabit()
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func createHabit() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        
        let newHabit = Habit(
            title: cleanTitle,
            category: cleanCategory.isEmpty ? "General" : cleanCategory,
            targetMinutes: targetMinutes,
            iconName: selectedIcon
        )
        
        modelContext.insert(newHabit)
        try? modelContext.save()
        dismiss()
    }
}
