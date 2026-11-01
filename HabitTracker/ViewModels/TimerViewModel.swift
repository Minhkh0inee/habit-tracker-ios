import SwiftUI
import Combine

public enum TimerState {
    case idle
    case running
    case paused
    case completed
}

@Observable
public final class TimerViewModel {
    public var state: TimerState = .idle
    public var selectedHabit: Habit?
    public var selectedDurationMinutes: Int = 25
    public var remainingSeconds: Int = 25 * 60
    public var totalSeconds: Int = 25 * 60
    public var showCompletionSheet: Bool = false
    
    // Background safe target timestamp
    private var targetDate: Date?
    private var timerCancellable: AnyCancellable?
    
    public init(habit: Habit? = nil, durationMinutes: Int = 25) {
        self.selectedHabit = habit
        self.selectedDurationMinutes = durationMinutes
        self.totalSeconds = durationMinutes * 60
        self.remainingSeconds = durationMinutes * 60
    }
    
    public var progress: Double {
        guard totalSeconds > 0 else { return 0.0 }
        let elapsed = Double(totalSeconds - remainingSeconds)
        return min(max(elapsed / Double(totalSeconds), 0.0), 1.0)
    }
    
    public var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var actualMinutesElapsed: Int {
        let elapsedSeconds = totalSeconds - remainingSeconds
        return max(1, Int(ceil(Double(elapsedSeconds) / 60.0)))
    }
    
    // MARK: - Actions
    public func setDuration(minutes: Int) {
        guard state == .idle else { return }
        selectedDurationMinutes = minutes
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
    }
    
    public func selectHabit(_ habit: Habit) {
        selectedHabit = habit
        if state == .idle {
            setDuration(minutes: habit.targetMinutes)
        }
    }
    
    public func start() {
        guard state == .idle || state == .paused else { return }
        
        if state == .idle {
            totalSeconds = selectedDurationMinutes * 60
            remainingSeconds = totalSeconds
        }
        
        targetDate = Date().addingTimeInterval(Double(remainingSeconds))
        state = .running
        triggerHaptic(.medium)
        
        startTimerSubscription()
    }
    
    public func pause() {
        guard state == .running else { return }
        updateRemainingFromTarget()
        targetDate = nil
        timerCancellable?.cancel()
        state = .paused
        triggerHaptic(.light)
    }
    
    public func resume() {
        start()
    }
    
    public func reset() {
        timerCancellable?.cancel()
        targetDate = nil
        remainingSeconds = selectedDurationMinutes * 60
        totalSeconds = remainingSeconds
        state = .idle
        triggerHaptic(.light)
    }
    
    public func finishEarly() {
        timerCancellable?.cancel()
        targetDate = nil
        state = .completed
        triggerHaptic(.heavy)
        showCompletionSheet = true
    }
    
    public func onTimeout() {
        timerCancellable?.cancel()
        targetDate = nil
        remainingSeconds = 0
        state = .completed
        triggerHaptic(.heavy)
        showCompletionSheet = true
    }
    
    public func resetAfterCompletion() {
        showCompletionSheet = false
        reset()
    }
    
    // MARK: - App Foreground Sync
    public func syncWithForeground() {
        guard state == .running, let targetDate else { return }
        let diff = Int(targetDate.timeIntervalSinceNow)
        if diff <= 0 {
            onTimeout()
        } else {
            remainingSeconds = diff
        }
    }
    
    // MARK: - Private Helpers
    private func startTimerSubscription() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard state == .running else { return }
        updateRemainingFromTarget()
        if remainingSeconds <= 0 {
            onTimeout()
        }
    }
    
    private func updateRemainingFromTarget() {
        guard let targetDate else { return }
        let diff = Int(ceil(targetDate.timeIntervalSinceNow))
        remainingSeconds = max(0, diff)
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
