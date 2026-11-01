import Foundation
import UserNotifications

public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderIdentifier = "DailyHabitReminder"
    
    private let isReminderEnabledKey = "isReminderEnabled"
    private let reminderHourKey = "reminderHour"
    private let reminderMinuteKey = "reminderMinute"
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Stored Preferences
    public var isReminderEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: isReminderEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: isReminderEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isReminderEnabledKey)
            if newValue {
                scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            } else {
                cancelDailyReminder()
            }
        }
    }
    
    public var reminderHour: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: reminderHourKey)
            return val == 0 && UserDefaults.standard.object(forKey: reminderHourKey) == nil ? 5 : val
        }
        set {
            UserDefaults.standard.set(newValue, forKey: reminderHourKey)
            if isReminderEnabled {
                scheduleDailyReminder(hour: newValue, minute: reminderMinute)
            }
        }
    }
    
    public var reminderMinute: Int {
        get {
            UserDefaults.standard.integer(forKey: reminderMinuteKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: reminderMinuteKey)
            if isReminderEnabled {
                scheduleDailyReminder(hour: reminderHour, minute: newValue)
            }
        }
    }
    
    // MARK: - Permission Request
    public func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted, let self = self, self.isReminderEnabled {
                    self.scheduleDailyReminder(hour: self.reminderHour, minute: self.reminderMinute)
                }
                completion(granted)
            }
        }
    }
    
    // MARK: - Schedule Daily Notification
    public func scheduleDailyReminder(hour: Int = 5, minute: Int = 0) {
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "Rise & Grind ☀️"
        content.body = "5:00 AM focus time: Stay consistent with DSA, Swift, System Design & Engineering!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error)")
            } else {
                print("Successfully scheduled daily reminder for \(String(format: "%02d:%02d", hour, minute))")
            }
        }
    }
    
    public func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }
    
    // MARK: - Send Test Notification (Fires in 2 seconds)
    public func sendTestNotification(delaySeconds: Double = 2, completion: @escaping () -> Void = {}) {
        requestAuthorization { granted in
            guard granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "Rise & Grind ☀️ (Test Push)"
            content.body = "5:00 AM focus time: Daily habit notification is working perfectly!"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delaySeconds), repeats: false)
            let request = UNNotificationRequest(identifier: "TestReminder_\(UUID().uuidString)", content: content, trigger: trigger)
            
            self.notificationCenter.add(request) { _ in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate (Show banner even when app is in foreground)
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }
}
