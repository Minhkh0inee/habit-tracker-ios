import Foundation
import UserNotifications

private enum NotificationDefaults {
    static let morningReminderHour: Int = 5
    static let morningReminderMinute: Int = 0
    static let eveningReminderHour: Int = 20
    static let eveningReminderMinute: Int = 0
    static let lateEveningGraceSeconds: TimeInterval = 15 * 60
    static let defaultTestDelaySeconds: Double = 2.0
    static let defaultTestStreak: Int = 3
}

private enum NotificationIdentifier {
    static let dailyReminder = "DailyHabitReminder"
    static let atRiskReminder = "AtRiskEveningStreakReminder"
    static let testDailyPrefix = "TestReminder_"
    static let testAtRiskPrefix = "TestAtRisk_"
}

private enum StorageKey {
    static let isReminderEnabled = "isReminderEnabled"
    static let reminderHour = "reminderHour"
    static let reminderMinute = "reminderMinute"
    static let isEveningStreakReminderEnabled = "isEveningStreakReminderEnabled"
    static let eveningReminderHour = "eveningReminderHour"
    static let eveningReminderMinute = "eveningReminderMinute"
}

private enum NotificationContentTemplate {
    static let morningTitle = "Rise & Grind ☀️"
    static let morningBody = "5:00 AM focus time: Stay consistent with DSA, Swift, System Design & Engineering!"
    static let morningTestTitle = "Rise & Grind ☀️ (Test Push)"
    static let morningTestBody = "5:00 AM focus time: Daily habit notification is working perfectly!"
    
    static func atRiskTitle(streak: Int) -> String {
        "🔥 Your \(streak)-Day Streak is At Risk!"
    }
    
    static let atRiskBody = "Don't let your streak break tonight! Complete just 1 habit session before midnight to keep the flame alive."
}

public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    public var isReminderEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: StorageKey.isReminderEnabled) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: StorageKey.isReminderEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.isReminderEnabled)
            if newValue {
                scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            } else {
                cancelDailyReminder()
            }
        }
    }
    
    public var reminderHour: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: StorageKey.reminderHour)
            return val == 0 && UserDefaults.standard.object(forKey: StorageKey.reminderHour) == nil ? NotificationDefaults.morningReminderHour : val
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.reminderHour)
            if isReminderEnabled {
                scheduleDailyReminder(hour: newValue, minute: reminderMinute)
            }
        }
    }
    
    public var reminderMinute: Int {
        get {
            UserDefaults.standard.integer(forKey: StorageKey.reminderMinute)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.reminderMinute)
            if isReminderEnabled {
                scheduleDailyReminder(hour: reminderHour, minute: newValue)
            }
        }
    }
    
    public var isEveningStreakReminderEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: StorageKey.isEveningStreakReminderEnabled) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: StorageKey.isEveningStreakReminderEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.isEveningStreakReminderEnabled)
            if !newValue {
                cancelAtRiskNotification()
            }
        }
    }
    
    public var eveningReminderHour: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: StorageKey.eveningReminderHour)
            return val == 0 && UserDefaults.standard.object(forKey: StorageKey.eveningReminderHour) == nil ? NotificationDefaults.eveningReminderHour : val
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.eveningReminderHour)
        }
    }
    
    public var eveningReminderMinute: Int {
        get {
            UserDefaults.standard.integer(forKey: StorageKey.eveningReminderMinute)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKey.eveningReminderMinute)
        }
    }
    
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
    
    public func scheduleDailyReminder(hour: Int = NotificationDefaults.morningReminderHour, minute: Int = NotificationDefaults.morningReminderMinute) {
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = NotificationContentTemplate.morningTitle
        content.body = NotificationContentTemplate.morningBody
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationIdentifier.dailyReminder, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    public func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.dailyReminder])
    }
    
    public func syncAtRiskNotification(habits: [Habit]) {
        guard isEveningStreakReminderEnabled else {
            cancelAtRiskNotification()
            return
        }
        
        let dict = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, $0.completedSessionDates) })
        let globalInfo = StreakEngine.globalStreakInfo(habitCompletedDates: dict)
        
        if globalInfo.isAtRisk && globalInfo.currentStreak > 0 {
            scheduleAtRiskNotification(streak: globalInfo.currentStreak, hour: eveningReminderHour, minute: eveningReminderMinute)
        } else {
            cancelAtRiskNotification()
        }
    }
    
    public func scheduleAtRiskNotification(streak: Int, hour: Int, minute: Int) {
        cancelAtRiskNotification()
        
        let calendar = Calendar.current
        let now = Date()
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        guard let scheduledDate = calendar.date(from: dateComponents) else { return }
        
        let trigger: UNNotificationTrigger
        if scheduledDate > now {
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        } else {
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return }
            let midnight = calendar.startOfDay(for: tomorrow)
            let reminderSoon = now.addingTimeInterval(NotificationDefaults.lateEveningGraceSeconds)
            if reminderSoon < midnight {
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: NotificationDefaults.lateEveningGraceSeconds, repeats: false)
            } else {
                return
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = NotificationContentTemplate.atRiskTitle(streak: streak)
        content.body = NotificationContentTemplate.atRiskBody
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: NotificationIdentifier.atRiskReminder, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    public func cancelAtRiskNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.atRiskReminder])
    }
    
    public func sendTestAtRiskNotification(
        streak: Int = NotificationDefaults.defaultTestStreak,
        delaySeconds: Double = NotificationDefaults.defaultTestDelaySeconds,
        completion: @escaping () -> Void = {}
    ) {
        requestAuthorization { granted in
            guard granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = NotificationContentTemplate.atRiskTitle(streak: streak)
            content.body = NotificationContentTemplate.atRiskBody
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delaySeconds), repeats: false)
            let request = UNNotificationRequest(identifier: "\(NotificationIdentifier.testAtRiskPrefix)\(UUID().uuidString)", content: content, trigger: trigger)
            
            self.notificationCenter.add(request) { _ in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    public func sendTestNotification(
        delaySeconds: Double = NotificationDefaults.defaultTestDelaySeconds,
        completion: @escaping () -> Void = {}
    ) {
        requestAuthorization { granted in
            guard granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = NotificationContentTemplate.morningTestTitle
            content.body = NotificationContentTemplate.morningTestBody
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delaySeconds), repeats: false)
            let request = UNNotificationRequest(identifier: "\(NotificationIdentifier.testDailyPrefix)\(UUID().uuidString)", content: content, trigger: trigger)
            
            self.notificationCenter.add(request) { _ in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }
}
