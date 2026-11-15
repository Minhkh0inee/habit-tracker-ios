import SwiftUI
import SwiftData

public struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: Int = 0
    @State private var timerViewModel = TimerViewModel()
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            TodayHabitsView(selectedTab: $selectedTab, timerViewModel: timerViewModel)
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }
                .tag(0)
            
            TimerView(viewModel: timerViewModel)
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("Proof Gallery", systemImage: "photo.stack")
                }
                .tag(2)
            
            HabitProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.xyaxis.line")
                }
                .tag(3)
        }
        .tint(AppTheme.textPrimary)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                timerViewModel.syncWithForeground()
            }
        }
        .onOpenURL { url in
            if url.scheme == "habittracker" {
                selectedTab = 0
            }
        }
    }
}
