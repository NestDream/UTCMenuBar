import Foundation
import UTCMenuBarLib

/// Tests for SettingsViewModel2 binding logic: store write-through, the isSyncing
/// re-entrancy guard, compactDate gating, .custom fontFamily store update, and
/// launch-at-login error rollback via a fake LoginItemControlling.

enum SettingsViewModel2Tests {

    @MainActor
    final class FakeLoginItem: LoginItemControlling {
        var isEnabled: Bool = false
        var requiresApproval: Bool = false
        var shouldThrow = false
        enum E: Error { case boom }
        func setEnabled(_ enabled: Bool) throws {
            if shouldThrow { throw E.boom }
            isEnabled = enabled
        }
    }

    private static func suite() -> (UserDefaults, String) {
        let name = "com.utcmenubar.test.svm2.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let d = UserDefaults(suiteName: name) else { fatalError("FAIL: suite create") }
        return (d, name)
    }

    @MainActor
    private static func makeVM(_ defaults: UserDefaults, login: FakeLoginItem = FakeLoginItem())
        -> (SettingsViewModel2, StyleOptionsStore, FakeLoginItem) {
        let style = StyleOptionsStore(defaults: defaults)
        let lang = LanguageStore(defaults: defaults)
        let vm = SettingsViewModel2(
            styleStore: style,
            languageStore: lang,
            loginItem: login,
            displayOptions: .default,
            displayDefaults: defaults,
            onDisplayOptionsChanged: { _ in }
        )
        return (vm, style, login)
    }

    static func testFontChangeWritesToStore() {
        print("  Running: testFontChangeWritesToStore...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }
            let (vm, style, _) = makeVM(defaults)
            vm.fontWeight = .bold
            guard style.current.fontWeight == .bold else {
                fatalError("FAIL: fontWeight change not written to store")
            }
        }
        print("  ✓ testFontChangeWritesToStore passed")
    }

    static func testCustomFontFamilyWritesToStore() {
        print("  Running: testCustomFontFamilyWritesToStore...")
        // Regression for bug #4: selecting .custom must still update the store.
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }
            let (vm, style, _) = makeVM(defaults)
            vm.fontFamily = .custom
            guard style.current.fontFamily == .custom else {
                fatalError("FAIL: .custom fontFamily not written to store (bug #4 regression)")
            }
        }
        print("  ✓ testCustomFontFamilyWritesToStore passed")
    }

    static func testIsSyncingGuardPreventsFeedbackLoop() {
        print("  Running: testIsSyncingGuardPreventsFeedbackLoop...")
        // Regression for bug #6: a store change must update the VM's published
        // values without those didSet handlers writing back to the store.
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }
            let (vm, style, _) = makeVM(defaults)

            var storeUpdates = 0
            style.addListener { _ in storeUpdates += 1 }

            // External store change → VM syncs in. Should fan out exactly once;
            // the VM's didSet must NOT re-call store.update.
            style.update { $0.textColor = .red }
            guard vm.textColor == .red else { fatalError("FAIL: VM did not sync from store") }
            guard storeUpdates == 1 else {
                fatalError("FAIL: feedback loop — expected 1 store update, got \(storeUpdates)")
            }
        }
        print("  ✓ testIsSyncingGuardPreventsFeedbackLoop passed")
    }

    static func testCompactDateGatedByShowDate() {
        print("  Running: testCompactDateGatedByShowDate...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }
            var saved: DisplayOptions?
            let style = StyleOptionsStore(defaults: defaults)
            let lang = LanguageStore(defaults: defaults)
            let vm = SettingsViewModel2(
                styleStore: style, languageStore: lang, loginItem: FakeLoginItem(),
                displayOptions: DisplayOptions(showDate: false, compactTime: true, compactDate: true),
                displayDefaults: defaults,
                onDisplayOptionsChanged: { saved = $0 }
            )
            saved = nil
            // showDate is false → toggling compactDate should NOT persist (orphaned save guard).
            vm.compactDate = false
            guard saved == nil else {
                fatalError("FAIL: compactDate change persisted while showDate=false")
            }
        }
        print("  ✓ testCompactDateGatedByShowDate passed")
    }

    static func testLaunchAtLoginSuccess() {
        print("  Running: testLaunchAtLoginSuccess...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }
            let login = FakeLoginItem()
            let (vm, _, _) = makeVM(defaults, login: login)
            vm.launchAtLogin = true
            guard login.isEnabled else { fatalError("FAIL: login item not enabled") }
            guard vm.launchAtLoginError == nil else { fatalError("FAIL: unexpected error") }
        }
        print("  ✓ testLaunchAtLoginSuccess passed")
    }

    static func testLaunchAtLoginErrorRollsBack() {
        print("  Running: testLaunchAtLoginErrorRollsBack...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }
            let login = FakeLoginItem()
            login.shouldThrow = true
            let (vm, _, _) = makeVM(defaults, login: login)

            vm.launchAtLogin = true   // setEnabled throws
            guard vm.launchAtLoginError != nil else {
                fatalError("FAIL: error not surfaced")
            }
            // Toggle should roll back to the actual (still false) state.
            guard vm.launchAtLogin == false else {
                fatalError("FAIL: toggle did not roll back after error, got \(vm.launchAtLogin)")
            }
        }
        print("  ✓ testLaunchAtLoginErrorRollsBack passed")
    }

    static func runAll() {
        print("SettingsViewModel2 Unit Tests")
        print("=============================")
        testFontChangeWritesToStore()
        testCustomFontFamilyWritesToStore()
        testIsSyncingGuardPreventsFeedbackLoop()
        testCompactDateGatedByShowDate()
        testLaunchAtLoginSuccess()
        testLaunchAtLoginErrorRollsBack()
        print("\nAll SettingsViewModel2 unit tests passed ✓")
    }
}
