import Foundation
import UTCMenuBarLib

/// Tests for ClockPopoverViewModel: time/date text output, timer start/stop
/// seam, and listener-driven refresh. @MainActor bodies via assumeIsolated.

enum ClockPopoverViewModelTests {

    private static func suite() -> (UserDefaults, String) {
        let name = "com.utcmenubar.test.popvm.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let d = UserDefaults(suiteName: name) else { fatalError("FAIL: suite create") }
        return (d, name)
    }

    private static func matches(_ text: String, pattern: String) -> Bool {
        text.range(of: pattern, options: .regularExpression) != nil
    }

    static func testTimeAndDateTextShape() {
        print("  Running: testTimeAndDateTextShape...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            // Full time: HH:mm:ss
            let full = ClockPopoverViewModel(
                languageStore: LanguageStore(defaults: defaults),
                displayOptionsProvider: { DisplayOptions(showDate: false, compactTime: false, compactDate: false) }
            )
            guard matches(full.timeText, pattern: #"^\d{2}:\d{2}:\d{2}$"#) else {
                fatalError("FAIL: full timeText should be HH:mm:ss, got '\(full.timeText)'")
            }

            // Compact time: HH:mm
            let compact = ClockPopoverViewModel(
                languageStore: LanguageStore(defaults: defaults),
                displayOptionsProvider: { DisplayOptions(showDate: false, compactTime: true, compactDate: false) }
            )
            guard matches(compact.timeText, pattern: #"^\d{2}:\d{2}$"#) else {
                fatalError("FAIL: compact timeText should be HH:mm, got '\(compact.timeText)'")
            }

            // Date is always the full form, independent of the menu bar's
            // date/compact settings: the popover is the detail view.
            for vm in [full, compact] {
                guard matches(vm.dateText, pattern: #"^\d{4}-\d{2}-\d{2}$"#) else {
                    fatalError("FAIL: dateText should be yyyy-MM-dd, got '\(vm.dateText)'")
                }
            }
        }
        print("  ✓ testTimeAndDateTextShape passed")
    }

    static func testStartStopTickingSeam() {
        print("  Running: testStartStopTickingSeam...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let vm = ClockPopoverViewModel(
                languageStore: LanguageStore(defaults: defaults),
                displayOptionsProvider: { .default }
            )
            guard !vm.isTicking else { fatalError("FAIL: should not tick before start") }
            vm.startTicking()
            guard vm.isTicking else { fatalError("FAIL: should tick after start") }
            vm.stopTicking()
            guard !vm.isTicking else { fatalError("FAIL: should not tick after stop") }
        }
        print("  ✓ testStartStopTickingSeam passed")
    }

    static func testLanguageListenerUpdatesProperty() {
        print("  Running: testLanguageListenerUpdatesProperty...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let langStore = LanguageStore(defaults: defaults)
            let vm = ClockPopoverViewModel(
                languageStore: langStore,
                displayOptionsProvider: { .default }
            )
            let other: AppLanguage = langStore.current == .en ? .zh : .en
            langStore.update(other)
            guard vm.language == other else {
                fatalError("FAIL: vm.language did not follow store, got \(vm.language) expected \(other)")
            }
        }
        print("  ✓ testLanguageListenerUpdatesProperty passed")
    }

    static func runAll() {
        print("ClockPopoverViewModel Unit Tests")
        print("================================")
        testTimeAndDateTextShape()
        testStartStopTickingSeam()
        testLanguageListenerUpdatesProperty()
        print("\nAll ClockPopoverViewModel unit tests passed ✓")
    }
}
