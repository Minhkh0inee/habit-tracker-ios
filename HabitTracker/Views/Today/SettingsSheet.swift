import SwiftUI
import SwiftData

private enum SettingsConstants {
    static let testPushDelaySeconds: Double = 2.0
    static let testAtRiskStreakDays: Int = 5
}

public struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEnabled: Bool = NotificationManager.shared.isReminderEnabled
    @State private var reminderDate: Date = {
        var comps = DateComponents()
        comps.hour = NotificationManager.shared.reminderHour
        comps.minute = NotificationManager.shared.reminderMinute
        return Calendar.current.date(from: comps) ?? Date()
    }()
    
    @State private var isEveningStreakEnabled: Bool = NotificationManager.shared.isEveningStreakReminderEnabled
    @State private var eveningReminderDate: Date = {
        var comps = DateComponents()
        comps.hour = NotificationManager.shared.eveningReminderHour
        comps.minute = NotificationManager.shared.eveningReminderMinute
        return Calendar.current.date(from: comps) ?? Date()
    }()
    
    @State private var showTestAlert: Bool = false
    @State private var showEveningTestAlert: Bool = false
    @State private var showResetConfirmation: Bool = false
    @State private var showAISyncSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Daily Morning Reminder").foregroundColor(AppTheme.textSecondary)) {
                    Toggle("Enable Daily Reminder", isOn: $isEnabled)
                        .onChange(of: isEnabled) { _, newValue in
                            if newValue {
                                NotificationManager.shared.requestAuthorization { granted in
                                    if granted {
                                        updateReminderTime()
                                    } else {
                                        isEnabled = false
                                    }
                                }
                            } else {
                                NotificationManager.shared.isReminderEnabled = false
                            }
                        }
                    
                    if isEnabled {
                        DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderDate) { _, _ in
                                updateReminderTime()
                            }
                        
                        Button(action: sendTest) {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Test Notification Push (Fires in 2s)")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                
                Section(
                    header: Text("Evening Streak Protection").foregroundColor(AppTheme.textSecondary),
                    footer: Text("Automatically alerts you in the evening if your streak has not been completed yet today.").foregroundColor(AppTheme.textSecondary).font(.caption)
                ) {
                    Toggle("At-Risk Evening Alert", isOn: $isEveningStreakEnabled)
                        .onChange(of: isEveningStreakEnabled) { _, newValue in
                            if newValue {
                                NotificationManager.shared.requestAuthorization { granted in
                                    if granted {
                                        updateEveningReminderTime()
                                    } else {
                                        isEveningStreakEnabled = false
                                    }
                                }
                            } else {
                                NotificationManager.shared.isEveningStreakReminderEnabled = false
                            }
                        }
                    
                    if isEveningStreakEnabled {
                        DatePicker("Alert Time", selection: $eveningReminderDate, displayedComponents: .hourAndMinute)
                            .onChange(of: eveningReminderDate) { _, _ in
                                updateEveningReminderTime()
                            }
                        
                        Button(action: sendEveningTest) {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("Test At-Risk Alert (Fires in 2s)")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                
                Section(header: Text("AI Interview Question Bank").foregroundColor(AppTheme.textSecondary)) {
                    Button(action: { showAISyncSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Sync Questions with Gemini AI")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                
                Section(header: Text("Storage & Privacy").foregroundColor(AppTheme.textSecondary)) {
                    HStack {
                        Text("Database Engine")
                        Spacer()
                        Text("SwiftData / SQLite")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    HStack {
                        Text("Cloud Sync")
                        Spacer()
                        Text("None (100% Local)")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    HStack {
                        Text("Photo Storage")
                        Spacer()
                        Text("Documents/Proofs/")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Section(header: Text("Data Management").foregroundColor(AppTheme.textSecondary)) {
                    Button(role: .destructive, action: { showResetConfirmation = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Progress & Clear History")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("About").foregroundColor(AppTheme.textSecondary)) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0 (Local Build)")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                }
            }
            .alert("Test Notification Scheduled", isPresented: $showTestAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Test banner will slide down from the top of your screen in 2 seconds! You can also lock your phone to test it on the lock screen.")
            }
            .alert("At-Risk Alert Scheduled", isPresented: $showEveningTestAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("🔥 Test at-risk alert will fire in 2 seconds! Lock your screen or stay in the app to see it.")
            }
            .confirmationDialog(
                "Reset All Progress?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Session History", role: .destructive) {
                    resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all session logs, photos, and progress. Your habits will remain, reset to 0 minutes.")
            }
            .sheet(isPresented: $showAISyncSheet) {
                AIQuestionSyncSheet()
            }
        }
    }
    
    private func updateReminderTime() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderDate)
        let minute = calendar.component(.minute, from: reminderDate)
        
        NotificationManager.shared.reminderHour = hour
        NotificationManager.shared.reminderMinute = minute
        NotificationManager.shared.isReminderEnabled = true
        NotificationManager.shared.scheduleDailyReminder(hour: hour, minute: minute)
    }
    
    private func updateEveningReminderTime() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: eveningReminderDate)
        let minute = calendar.component(.minute, from: eveningReminderDate)
        
        NotificationManager.shared.eveningReminderHour = hour
        NotificationManager.shared.eveningReminderMinute = minute
        NotificationManager.shared.isEveningStreakReminderEnabled = true
    }
    
    private func sendTest() {
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                NotificationManager.shared.sendTestNotification(delaySeconds: SettingsConstants.testPushDelaySeconds)
                showTestAlert = true
            }
        }
    }
    
    private func sendEveningTest() {
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                NotificationManager.shared.sendTestAtRiskNotification(
                    streak: SettingsConstants.testAtRiskStreakDays,
                    delaySeconds: SettingsConstants.testPushDelaySeconds
                )
                showEveningTestAlert = true
            }
        }
    }
    
    private func resetAllData() {
        do {
            let sessionDescriptor = FetchDescriptor<HabitSession>()
            let allSessions = try modelContext.fetch(sessionDescriptor)
            for session in allSessions {
                if let photoName = session.photoFileName {
                    ImageStorageService.shared.deleteProofImage(named: photoName)
                }
                modelContext.delete(session)
            }
            
            let habitDescriptor = FetchDescriptor<Habit>()
            let allHabits = try modelContext.fetch(habitDescriptor)
            for habit in allHabits {
                habit.sessions.removeAll()
            }
            
            try modelContext.save()
            StreakWidgetSnapshotService.shared.saveSnapshot(from: allHabits)
            dismiss()
        } catch {
            print("Failed to reset all data: \(error)")
        }
    }
}
