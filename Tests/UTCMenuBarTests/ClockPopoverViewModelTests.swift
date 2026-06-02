import Foundation
import UTCMenuBarLib

/// Tests for ClockPopoverViewModel: time-string output, timer start/stop seam,
/// and listener-driven refresh. @MainActor bodies via assumeIsolated.

enum ClockPopoverViewModelTests {

    private static func suite() -> (UserDefaults, String) {
        let name = "com.utcmenubar.test.popvm.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let d = UserDefaults(suiteName: name) else { fatalError("FAIL: suite create") }
        return (d, name)
    }

    static func testCurrentTimeFormat() {
        print("  Running: testCurrentTimeFormat...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let styleStore = StyleOptionsStore(defaults: defaults)
            styleStore.update { $0.iconPrefix = .none }
            let langStore = LanguageStore(defaults: defaults)
            let opts = DisplayOptions(showDate: false, compactTime: false, compactDate: false)

            let vm = ClockPopoverViewModel(
                styleStore: styleStore,
                languageStore: langStore,
                displayOptionsProvider: { opts }
            )
            // No icon prefix, time-only → "<HH:mm:ss> UTC"
            guard vm.currentTime.hasSuffix(" UTC") else {
                fatalError("FAIL: expected ' UTC' suffix, got '\(vm.currentTime)'")
            }
            guard !vm.currentTime.contains("🌐") else {
                fatalError("FAIL: icon prefix .none should produce no globe, got '\(vm.currentTime)'")
            }
        }
        print("  ✓ testCurrentTimeFormat passed")
    }

    static func testStartStopTickingSeam() {
        print("  Running: testStartStopTickingSeam...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let vm = ClockPopoverViewModel(
                styleStore: StyleOptionsStore(defaults: defaults),
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
                styleStore: StyleOptionsStore(defaults: defaults),
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

    static func testStyleChangeRefreshesTime() {
        print("  Running: testStyleChangeRefreshesTime...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let styleStore = StyleOptionsStore(defaults: defaults)
            styleStore.update { $0.iconPrefix = .none }
            let vm = ClockPopoverViewModel(
                styleStore: styleStore,
                languageStore: LanguageStore(defaults: defaults),
                displayOptionsProvider: { .default }
            )
            guard !vm.currentTime.contains("🌐") else { fatalError("FAIL: precondition") }
            styleStore.update { $0.iconPrefix = .globe }
            guard vm.currentTime.contains("🌐") else {
                fatalError("FAIL: style change did not refresh time, got '\(vm.currentTime)'")
            }
        }
        print("  ✓ testStyleChangeRefreshesTime passed")
    }

    static func runAll() {
        print("ClockPopoverViewModel Unit Tests")
        print("================================")
        testCurrentTimeFormat()
        testStartStopTickingSeam()
        testLanguageListenerUpdatesProperty()
        testStyleChangeRefreshesTime()
        print("\nAll ClockPopoverViewModel unit tests passed ✓")
    }
}
