import Foundation
import UTCMenuBarLib

/// Tests for the three observable stores (load / update / persist / listener fan-out / token removal).
/// All store APIs are @MainActor, so bodies run inside MainActor.assumeIsolated.

enum StoreTests {

    private static func suite() -> (UserDefaults, String) {
        let name = "com.utcmenubar.test.store.\(ProcessInfo.processInfo.globallyUniqueString)"
        guard let d = UserDefaults(suiteName: name) else { fatalError("FAIL: suite create") }
        return (d, name)
    }

    static func testStyleStoreUpdatePersistsAndNotifies() {
        print("  Running: testStyleStoreUpdatePersistsAndNotifies...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let store = StyleOptionsStore(defaults: defaults)
            var observed: StyleOptions?
            store.addListener { observed = $0 }

            store.update { $0.textColor = .blue }

            guard store.current.textColor == .blue else { fatalError("FAIL: current not updated") }
            guard observed?.textColor == .blue else { fatalError("FAIL: listener not notified") }
            // Persisted: a fresh store from the same defaults sees it.
            let reloaded = StyleOptionsStore(defaults: defaults)
            guard reloaded.current.textColor == .blue else { fatalError("FAIL: not persisted") }
        }
        print("  ✓ testStyleStoreUpdatePersistsAndNotifies passed")
    }

    static func testRemoveListenerStopsNotifications() {
        print("  Running: testRemoveListenerStopsNotifications...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let store = StyleOptionsStore(defaults: defaults)
            var count = 0
            let token = store.addListener { _ in count += 1 }

            store.update { $0.fontSize = .large }
            guard count == 1 else { fatalError("FAIL: expected 1 notification, got \(count)") }

            store.removeListener(token)
            store.update { $0.fontSize = .small }
            guard count == 1 else { fatalError("FAIL: removed listener still fired, count=\(count)") }
        }
        print("  ✓ testRemoveListenerStopsNotifications passed")
    }

    static func testMultipleListenersAllFire() {
        print("  Running: testMultipleListenersAllFire...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let store = StyleOptionsStore(defaults: defaults)
            var a = 0, b = 0
            store.addListener { _ in a += 1 }
            store.addListener { _ in b += 1 }
            store.update { $0.decorator = .brackets }
            guard a == 1 && b == 1 else { fatalError("FAIL: not all listeners fired a=\(a) b=\(b)") }
        }
        print("  ✓ testMultipleListenersAllFire passed")
    }

    static func testLanguageStoreNoNotifyWhenUnchanged() {
        print("  Running: testLanguageStoreNoNotifyWhenUnchanged...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let store = LanguageStore(defaults: defaults)
            var count = 0
            store.addListener { _ in count += 1 }
            store.update(store.current)  // same value → no notification
            guard count == 0 else { fatalError("FAIL: unchanged update fired listener, count=\(count)") }

            let other: AppLanguage = store.current == .en ? .zh : .en
            store.update(other)
            guard count == 1 else { fatalError("FAIL: changed update should fire once, got \(count)") }
        }
        print("  ✓ testLanguageStoreNoNotifyWhenUnchanged passed")
    }

    static func testConverterStorePersists() {
        print("  Running: testConverterStorePersists...")
        MainActor.assumeIsolated {
            let (defaults, name) = suite()
            defer { defaults.removePersistentDomain(forName: name) }

            let store = TimezoneConverterStore(defaults: defaults)
            store.update { $0.targetTimezone = "Asia/Tokyo" }
            let reloaded = TimezoneConverterStore(defaults: defaults)
            guard reloaded.current.targetTimezone == "Asia/Tokyo" else {
                fatalError("FAIL: converter store not persisted: \(reloaded.current.targetTimezone)")
            }
        }
        print("  ✓ testConverterStorePersists passed")
    }

    static func runAll() {
        print("Store Unit Tests")
        print("================")
        testStyleStoreUpdatePersistsAndNotifies()
        testRemoveListenerStopsNotifications()
        testMultipleListenersAllFire()
        testLanguageStoreNoNotifyWhenUnchanged()
        testConverterStorePersists()
        print("\nAll Store unit tests passed ✓")
    }
}
