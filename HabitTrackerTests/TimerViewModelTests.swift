import XCTest
@testable import HabitTracker

final class TimerViewModelTests: XCTestCase {
    
    func testInitialState() {
        let vm = TimerViewModel(durationMinutes: 25)
        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(vm.selectedDurationMinutes, 25)
        XCTAssertEqual(vm.totalSeconds, 1500)
        XCTAssertEqual(vm.remainingSeconds, 1500)
        XCTAssertEqual(vm.formattedRemainingTime, "25:00")
        XCTAssertEqual(vm.progress, 0.0)
        XCTAssertFalse(vm.showCompletionSheet)
    }
    
    func testSetDuration_WhenIdle() {
        let vm = TimerViewModel(durationMinutes: 25)
        vm.setDuration(minutes: 45)
        
        XCTAssertEqual(vm.selectedDurationMinutes, 45)
        XCTAssertEqual(vm.totalSeconds, 2700)
        XCTAssertEqual(vm.remainingSeconds, 2700)
        XCTAssertEqual(vm.formattedRemainingTime, "45:00")
    }
    
    func testSetDuration_IgnoredWhenRunning() {
        let vm = TimerViewModel(durationMinutes: 25)
        vm.start()
        vm.setDuration(minutes: 60)
        
        XCTAssertEqual(vm.selectedDurationMinutes, 25)
        XCTAssertEqual(vm.totalSeconds, 1500)
    }
    
    func testStartAndPauseAndResume() {
        let vm = TimerViewModel(durationMinutes: 25)
        vm.start()
        XCTAssertEqual(vm.state, .running)
        
        vm.pause()
        XCTAssertEqual(vm.state, .paused)
        
        vm.resume()
        XCTAssertEqual(vm.state, .running)
    }
    
    func testReset() {
        let vm = TimerViewModel(durationMinutes: 30)
        vm.start()
        vm.reset()
        
        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(vm.remainingSeconds, 1800)
        XCTAssertEqual(vm.totalSeconds, 1800)
        XCTAssertEqual(vm.formattedRemainingTime, "30:00")
        XCTAssertFalse(vm.showCompletionSheet)
    }
    
    func testFinishEarly() {
        let vm = TimerViewModel(durationMinutes: 25)
        vm.start()
        vm.finishEarly()
        
        XCTAssertEqual(vm.state, .completed)
        XCTAssertTrue(vm.showCompletionSheet)
    }
    
    func testOnTimeout() {
        let vm = TimerViewModel(durationMinutes: 25)
        vm.start()
        vm.onTimeout()
        
        XCTAssertEqual(vm.state, .completed)
        XCTAssertEqual(vm.remainingSeconds, 0)
        XCTAssertEqual(vm.formattedRemainingTime, "00:00")
        XCTAssertEqual(vm.progress, 1.0)
        XCTAssertTrue(vm.showCompletionSheet)
    }
    
    func testFormattedRemainingTime() {
        let vm = TimerViewModel(durationMinutes: 1)
        vm.remainingSeconds = 65
        XCTAssertEqual(vm.formattedRemainingTime, "01:05")
        
        vm.remainingSeconds = 9
        XCTAssertEqual(vm.formattedRemainingTime, "00:09")
        
        vm.remainingSeconds = 0
        XCTAssertEqual(vm.formattedRemainingTime, "00:00")
    }
    
    func testActualMinutesElapsed() {
        let vm = TimerViewModel(durationMinutes: 25) // 1500s total
        
        // 0 seconds elapsed -> max(1, ceil(0)) = 1
        XCTAssertEqual(vm.actualMinutesElapsed, 1)
        
        // 10 seconds elapsed -> ceil(10/60) = 1
        vm.remainingSeconds = 1490
        XCTAssertEqual(vm.actualMinutesElapsed, 1)
        
        // 65 seconds elapsed -> ceil(65/60) = 2
        vm.remainingSeconds = 1435
        XCTAssertEqual(vm.actualMinutesElapsed, 2)
        
        // 1500 seconds elapsed -> ceil(1500/60) = 25
        vm.remainingSeconds = 0
        XCTAssertEqual(vm.actualMinutesElapsed, 25)
    }
    
    func testProgressClamping() {
        let vm = TimerViewModel(durationMinutes: 10) // 600s total
        XCTAssertEqual(vm.progress, 0.0)
        
        vm.remainingSeconds = 300
        XCTAssertEqual(vm.progress, 0.5)
        
        vm.remainingSeconds = 0
        XCTAssertEqual(vm.progress, 1.0)
        
        // Negative remaining seconds clamped to 1.0
        vm.remainingSeconds = -50
        XCTAssertEqual(vm.progress, 1.0)
    }
}
