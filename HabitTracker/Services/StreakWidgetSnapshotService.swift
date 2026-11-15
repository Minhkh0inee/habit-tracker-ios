import Foundation
import WidgetKit

public final class StreakWidgetSnapshotService {
    public static let shared = StreakWidgetSnapshotService()
    
    public static let appGroupIdentifier = "group.com.habittracker.app"
    private static let storageKey = "streak_widget_data"
    
    private var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: Self.appGroupIdentifier) ?? UserDefaults.standard
    }
    
    private init() {}
    
    public func save(_ data: StreakWidgetData) {
        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults.set(encoded, forKey: Self.storageKey)
            sharedDefaults.synchronize()
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    public func readSnapshot() -> StreakWidgetData {
        guard let data = sharedDefaults.data(forKey: Self.storageKey),
              let snapshot = try? JSONDecoder().decode(StreakWidgetData.self, from: data) else {
            return .empty
        }
        return snapshot
    }
}
